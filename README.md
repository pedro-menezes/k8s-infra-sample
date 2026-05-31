# k8s-infra

Infraestrutura como código para provisionamento de um cluster Kubernetes gerenciado no Azure, com pipeline de CI/CD, GitOps via ArgoCD e gerenciamento de secrets via Azure Key Vault.

---

## Estrutura do repositório

```
k8s-infra/
├── app/                        # Aplicação de exemplo (nginx)
│   ├── Dockerfile
│   └── index.html
├── iac/                        # Infraestrutura como código
│   ├── bootstrap/              # Provisionamento do state remoto (roda uma vez)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── enviroments/
│   │   ├── terragrunt.hcl      # Configurações raiz (provider, backend, tags)
│   │   ├── production/
│   │   │   └── terragrunt.hcl
│   │   └── staging/
│   │       └── terragrunt.hcl
│   └── modules/
│       ├── aks-cluster/        # Módulo agregador
│       ├── az-aks/             # Cluster AKS + Flux
│       ├── az-vnet/            # VNet, subnets, NSG, NAT Gateway
│       ├── az-id/              # User Assigned Identity
│       ├── az-kv/              # Azure Key Vault
│       ├── az-psql/            # PostgreSQL Flexible Server
│       ├── az-cr/              # Azure Container Registry
│       └── az-storage/         # Storage Account
├── manifests/
│   ├── apps/
│   │   └── production/
│   │       └── sample/         # Manifests da aplicação de exemplo
│   │           ├── deployment.yaml
│   │           ├── service.yaml
│   │           ├── secret.yaml
│   │           ├── hpa.yaml
│   │           └── pdb.yaml
│   └── argocd-apps/
│       ├── production/         # Applications do ArgoCD para production
│       │   ├── sample.yaml
│       │   ├── traefik.yaml
│       │   └── akv2k8s.yaml
│       ├── staging/            # Applications do ArgoCD para staging
│       │   ├── traefik.yaml
│       │   └── akv2k8s.yaml
│       ├── root-production.yaml
│       └── root-staging.yaml
└── .github/
    └── workflows/
        ├── app.yaml            # Build, push e deploy da aplicação
        └── infra.yaml          # Validação e apply da infraestrutura
```

---

## Pré-requisitos

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.11
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/) >= 0.82
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) >= 2.60
- [kubectl](https://kubernetes.io/docs/tasks/tools/) >= 1.29

---

## Como rodar localmente

### 1. Autenticar no Azure

```bash
az login
az account set --subscription "<subscription-id>"
```

### 2. Provisionar o state remoto (apenas uma vez)

```bash
cd iac/bootstrap
terraform init
terraform apply
```

### 3. Descomentar o backend no `terragrunt.hcl` raiz

Após o bootstrap, descomente os blocos `remote_state` e `generate "backend"` em `iac/enviroments/terragrunt.hcl`.

### 4. Provisionar a infraestrutura

```bash
# Staging
cd iac/enviroments/staging
terragrunt apply

# Production
cd iac/enviroments/production
terragrunt apply
```

### 5. Configurar o kubectl

```bash
az aks get-credentials \
  --resource-group rg-cluster-prd \
  --name aks-cluster-prd-brs-001
```

### 6. Instalar o ArgoCD (feito automaticamente pelo Terraform via null_resource)

Caso precise instalar manualmente:

```bash
kubectl create namespace argocd
kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 7. Aplicar o App of Apps

```bash
kubectl apply -f manifests/root-production.yaml
kubectl apply -f manifests/root-staging.yaml
```

---

## Decisões técnicas

### Cloud Provider — Azure (AKS)

Optei pelo Azure por ser o provider com o qual tenho mais familiaridade e experiência prática. O AKS é uma solução madura de Kubernetes gerenciado, com boa integração nativa com os demais serviços utilizados (Key Vault, ACR, PostgreSQL), o que reduz a complexidade de configuração e o tempo de implementação.

### Terragrunt

Escolhi o Terragrunt para gerenciar múltiplos ambientes sem duplicação de código. A ferramenta permite reaproveitar os mesmos módulos Terraform com configurações distintas por ambiente via `inputs`, eliminando a necessidade de copiar arquivos entre `staging` e `production`. Foi também uma oportunidade de aprofundar o conhecimento na ferramenta.

### ArgoCD

Optei pelo ArgoCD por experiência prévia e por ser uma ferramenta completa de GitOps, com interface gráfica, suporte a App of Apps, controle granular de sync por ambiente e ampla adoção na comunidade. A interface facilita a visualização do estado dos deploys e a aprovação manual em production.

### akv2k8s (Azure Key Vault to Kubernetes)

Escolhido por experiência prévia. O akv2k8s sincroniza secrets do Azure Key Vault diretamente como `Secret` nativo do Kubernetes, sem necessidade de montar volumes nos pods — o que simplifica a configuração dos deployments em comparação ao CSI Driver.

### Estratégia GitOps — branches + diretórios

A promoção entre ambientes é feita por branches:

| Branch | Ambiente |
|---|---|
| `stage` | Staging |
| `main` | Production |

Cada branch possui seu próprio conjunto de manifests em `manifests/apps/staging/` e `manifests/apps/production/`. O ArgoCD monitora cada branch independentemente via `root-staging.yaml` e `root-production.yaml`.

- **Staging**: sincronização automática (`automated: true`)
- **Production**: sincronização manual — requer aprovação na UI do ArgoCD

Essa estratégia foi escolhida por ser simples de entender e operar, com separação clara entre ambientes. Em alguns casos, como para ferramentas de infraestrutura (Traefik, akv2k8s), a separação é feita por diretórios dentro da mesma branch.

### Bootstrap separado para o state

O state do Terraform não pode ser gerenciado pelo próprio Terraform. A solução adotada foi um módulo `bootstrap` com backend local, que provisiona o Storage Account no Azure. Após o bootstrap, o backend é ativado nos demais módulos.

---
 
## O que faria diferente com mais tempo
 
- **Instalação do ArgoCD via provider Helm** — a solução atual usa `null_resource` com `local-exec`, que depende do `kubectl` instalado no runner do pipeline. O provider Helm gerenciaria o ciclo de vida do ArgoCD diretamente pelo Terraform, com controle de versão, rollback e configuração declarativa. A limitação encontrada foi que o provider Helm precisa dos outputs do cluster AKS para se conectar, o que exigiria uma unit Terragrunt separada para o Helm — o que aumentaria a complexidade do projeto para o prazo disponível.
- **Configuração completa do Traefik com Gateway API** — o manifesto do Traefik foi criado com suporte à Gateway API habilitado, mas os recursos `GatewayClass`, `Gateway` e `HTTPRoute` da aplicação não foram finalizados. Com mais tempo, configuraria o roteamento completo com TLS, middlewares de autenticação e rate limiting.
- **Workload Identity em vez de Service Principal** — a autenticação do pipeline no Azure atualmente usa credenciais de Service Principal via `AZURE_CREDENTIALS`. O Workload Identity elimina credenciais de longa duração, federando a identidade do GitHub Actions diretamente com o Azure AD — mais seguro e sem necessidade de rotacionar secrets.
- **Política de rede (NetworkPolicy)** nos namespaces para restringir comunicação entre pods.
---
 
## Riscos e limitações
 
- **`null_resource` para instalar o ArgoCD** — depende do `kubectl` e `az` instalados no runner do GitHub Actions. Uma falha nesse step não é detectada pelo Terraform como erro de infraestrutura.
- **State local no bootstrap** — o `terraform.tfstate` do bootstrap precisa ser guardado manualmente ou commitado no repositório (com cuidado, pois pode conter dados sensíveis).
- **Credenciais do ACR via username/password** — o ideal seria usar Workload Identity ou Managed Identity para autenticação no ACR, eliminando os secrets `ACR_USERNAME` e `ACR_PASSWORD` do pipeline.
- **`terragrunt.hcl` como root** — o Terragrunt emite um warning sobre isso. A migração para `root.hcl` está documentada mas não foi feita para não aumentar o escopo do desafio.
- **Sem testes automatizados** nos módulos Terraform — mudanças nos módulos podem quebrar ambientes sem aviso prévio.
 
