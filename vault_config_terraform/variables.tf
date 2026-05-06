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

variable "windows_username" {
  description = "the HCP Vault namespace we will use for mounting the database secret engine"
  default     = "Administrator"
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