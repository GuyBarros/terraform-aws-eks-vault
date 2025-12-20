

module "vault" {
  # I'd have to remove all the provider from the modules, not today
  # for_each = toset(var.cluster_names)
  source = "./modules"

  aws_region         = var.region
  cluster_name = var.cluster_name
  vault_license = var.vault_license
  cluster_version = var.cluster_version
  vault_namespace = var.vault_namespace
  
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "vault_cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.vault.cluster_name
}

output "vault_access_instructions" {
  description = "Instructions for accessing Vault with TLS"
  value       = module.vault.vault_access_instructions
}