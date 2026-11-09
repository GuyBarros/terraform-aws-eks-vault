
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "primary"
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "is_hashicorp" {
  description = "Whether the AMI is from HashiCorp or Canonical"
  type        = bool
  default     = false
}

variable "vault_namespace" {
  description = "Kubernetes namespace for Vault"
  type        = string
  default     = "vault"
}

variable "vault_version" {
  description = "Vault version"
  type        = string
  default     = "2.2.1-ent"
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

variable "postgres_username" {
  description = "Username that will be used to create the AWS Postgres instance"
  default     = "postgresql"
}

variable "postgres_password" {
  description = "Password that will be used to create the AWS Postgres instance"
  default     = "YourPwdShouldBeLongAndSecure!"
}

  variable "postgres_db_name" {
  description = "Db_name that will be used to create the AWS Postgres instance"
  default     = "postgress"
}

variable "mysql_username" {
  description = "Username that will be used to create the AWS mysql instance"
  default     = "foo"
}

variable "mysql_password" {
  description = "Password that will be used to create the AWS mysql instance"
  default     = "YourPwdShouldBeLongAndSecure!"
}

  variable "mysql_db_name" {
  description = "Db_name that will be used to create the AWS mysql instance"
  default     = "mydb"
}

variable "documentdb_master_username" {
  description = "Username that will be used to create the AWS Postgres instance"
  default     = "postgresql"
}

variable "documentdb_master__password" {
  description = "Password that will be used to create the AWS Postgres instance"
  default     = "YourPwdShouldBeLongAndSecure!"
}

variable "windows_instance_type_worker" {
  description = "The type(size) of data worker (consul, nomad, etc)."
  default     = "t3.medium"
}

variable "public_key" {
  description = "The contents of the SSH public key to use for connecting to the cluster."
}

// EDR variables
variable "deployment_id" {
  description = "Deployment identifier used as the Uptycs cluster name"
  type        = string
}

variable "enable_k8sosquery" {
  description = "Whether to install the k8sosquery Helm release"
  type        = bool
}

variable "enable_kubequery" {
  description = "Whether to install the kubequery Helm release"
  type        = bool
}

variable "k8sosquery_values_path" {
  description = "Absolute path to the k8sosquery Helm values file"
  type        = string
}

variable "kubequery_values_path" {
  description = "Absolute path to the kubequery Helm values file"
  type        = string
}