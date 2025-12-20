
# KMS Key for Vault Auto-unseal
resource "aws_kms_key" "vault" {
  description             = "KMS key for Vault auto-unseal"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name        = "${var.cluster_name}-vault-unseal"
    Environment = "dev"
    Terraform   = "true"
  }
}

resource "aws_kms_alias" "vault" {
  name          = "alias/${var.cluster_name}-vault-unseal"
  target_key_id = aws_kms_key.vault.key_id
}
