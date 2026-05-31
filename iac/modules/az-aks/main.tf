resource "azurerm_role_assignment" "this" {
  principal_id         = var.user_assigned_principal_id
  role_definition_name = "Network Contributor"
  scope                = var.subnet_id
}

resource "azurerm_kubernetes_cluster" "this" {
  name                = "aks-${var.project}-${var.env}-${var.location_code}-001"
  location            = var.location
  resource_group_name = var.resource_group
  dns_prefix          = "${var.project}-${var.env}"

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }
  
  default_node_pool {
    name           = var.default_node_pool_name
    node_count     = var.node_count
    vm_size        = var.node_size
    vnet_subnet_id = var.subnet_id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [var.user_assigned_id]
  }
}

resource "null_resource" "argocd" {
  provisioner "local-exec" {
    command = <<EOT
      az aks get-credentials \
        --resource-group ${var.resource_group} \
        --name aks-${var.project}-${var.env}-${var.location_code}-001 \
        --overwrite-existing

      kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
      kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    EOT
  }

  depends_on = [azurerm_kubernetes_cluster.this]
}