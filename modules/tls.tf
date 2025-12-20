
# TLS Certificate and Key for Vault
resource "tls_private_key" "vault_ca" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "vault_ca" {
  private_key_pem = tls_private_key.vault_ca.private_key_pem

  subject {
    common_name  = "Vault CA"
    organization = "HashiCorp"
  }

  validity_period_hours = 87600 # 10 years
  is_ca_certificate     = true

  allowed_uses = [
    "cert_signing",
    "key_encipherment",
    "digital_signature",
    "crl_signing",
  ]
}

resource "tls_private_key" "vault" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "vault" {
  private_key_pem = tls_private_key.vault.private_key_pem

  subject {
    common_name  = var.vault_domain
    organization = "HashiCorp"
  }

  dns_names = [
    var.vault_domain,
    "vault",
    "vault.${var.vault_namespace}",
    "vault.${var.vault_namespace}.svc",
    "vault.${var.vault_namespace}.svc.cluster.local",
    "vault-0.vault-internal",
    "vault-0.vault-internal.${var.vault_namespace}",
    "vault-0.vault-internal.${var.vault_namespace}.svc",
    "vault-0.vault-internal.${var.vault_namespace}.svc.cluster.local",
    "vault-1.vault-internal",
    "vault-1.vault-internal.${var.vault_namespace}",
    "vault-1.vault-internal.${var.vault_namespace}.svc",
    "vault-1.vault-internal.${var.vault_namespace}.svc.cluster.local",
    "vault-2.vault-internal",
    "vault-2.vault-internal.${var.vault_namespace}",
    "vault-2.vault-internal.${var.vault_namespace}.svc",
    "vault-2.vault-internal.${var.vault_namespace}.svc.cluster.local",
    "vault-active",
    "vault-active.${var.vault_namespace}",
    "vault-active.${var.vault_namespace}.svc",
    "vault-active.${var.vault_namespace}.svc.cluster.local",
    "vault-standby",
    "vault-standby.${var.vault_namespace}",
    "vault-standby.${var.vault_namespace}.svc",
    "vault-standby.${var.vault_namespace}.svc.cluster.local",
    "localhost",
    "*.elb.amazonaws.com",
  ]

  ip_addresses = [
    "127.0.0.1",
  ]
}

resource "tls_locally_signed_cert" "vault" {
  cert_request_pem   = tls_cert_request.vault.cert_request_pem
  ca_private_key_pem = tls_private_key.vault_ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.vault_ca.cert_pem

  validity_period_hours = 8760 # 1 year

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}
