
# Create namespace for Vault
resource "kubernetes_namespace" "vault" {
  metadata {
    name = var.vault_namespace
  }

  depends_on = [module.eks]
}

# Kubernetes Secret for TLS certificates
resource "kubernetes_secret" "vault_tls" {
  metadata {
    name      = "vault-tls"
    namespace = var.vault_namespace
  }

  data = {
    "vault.crt" = tls_locally_signed_cert.vault.cert_pem
    "vault.key" = tls_private_key.vault.private_key_pem
    "vault.ca"  = tls_self_signed_cert.vault_ca.cert_pem
  }

  type = "Opaque"

  depends_on = [kubernetes_namespace.vault]
}

# Kubernetes Secret for Vault License
resource "kubernetes_secret" "vault_license" {
  metadata {
    name      = "vault-enterprise-license"
    namespace = var.vault_namespace
  }

  data = {
    license = var.vault_license
  }

  depends_on = [kubernetes_namespace.vault]
}

# StorageClass for Vault (using EBS CSI)
resource "kubernetes_storage_class" "vault_ebs" {
  metadata {
    name = "vault-ebs-sc"
  }

  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Retain"
  allow_volume_expansion = true
  volume_binding_mode    = "WaitForFirstConsumer"

  parameters = {
    type      = "gp3"
    encrypted = "true"
    fsType    = "ext4"
  }

  depends_on = [module.eks]
}
