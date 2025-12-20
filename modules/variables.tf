
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "vault"
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "vault_namespace" {
  description = "Kubernetes namespace for Vault"
  type        = string
  default     = "vault"
}

variable "vault_license" {
  description = "Vault Enterprise license key"
  type        = string
  sensitive   = true
}

variable "vault_domain" {
  description = "Domain name for Vault (e.g., vault.example.com)"
  type        = string
  default     = "vault.local"
}
