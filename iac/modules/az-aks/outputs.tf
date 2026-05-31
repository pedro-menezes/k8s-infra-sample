output "azure_kubernetes_cluster_id" {
  value       = azurerm_kubernetes_cluster.this.id
  description = "ID do cluster AKS"
}

output "kube_config" {
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
  description = "Kubeconfig completo"
}

output "host" {
  value       = azurerm_kubernetes_cluster.this.kube_config[0].host
  sensitive   = true
  description = "Endpoint do cluster"
}

output "client_certificate" {
  value       = base64decode(azurerm_kubernetes_cluster.this.kube_config[0].client_certificate)
  sensitive   = true
  description = "Certificado do cliente"
}

output "client_key" {
  value       = base64decode(azurerm_kubernetes_cluster.this.kube_config[0].client_key)
  sensitive   = true
  description = "Chave do cliente"
}

output "cluster_ca_certificate" {
  value       = base64decode(azurerm_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate)
  sensitive   = true
  description = "CA certificate do cluster"
}

output "key_vault_secrets_provider_client_id" {
  value       = azurerm_kubernetes_cluster.this.key_vault_secrets_provider[0].secret_identity[0].client_id
  description = "Client ID da identity do CSI"
}