
variable "primary_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "secondary_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}


variable "primary_cluster_name" {
  description = "Name of the primary EKS cluster"
  type        = string
  default     = "primary"
}

variable "secondary_cluster_name" {
  description = "Name of the secondary EKS cluster"
  type        = string
  default     = "secondary"
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


variable "public_key" {
  description = "The contents of the SSH public key to use for connecting to the cluster."
}

variable "is_hashicorp" {
  description = "Whether the AMI is from HashiCorp or Canonical"
  type        = bool
  default     = true
}