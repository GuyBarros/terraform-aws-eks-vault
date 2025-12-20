
# Helm Release for Vault Enterprise
resource "helm_release" "vault" {
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  version    = "0.27.0"
  namespace  = var.vault_namespace

  values = [
    yamlencode({
      global = {
        enabled = true
        tlsDisable = false
      }
      
      injector = {
        enabled = true
      }

      server = {
        image = {
          repository = "hashicorp/vault-enterprise"
          tag        = "1.21.1-ent"
        }

        enterpriseLicense = {
          secretName = kubernetes_secret.vault_license.metadata[0].name
          secretKey  = "license"
        }

        serviceAccount = {
          create = true
          name   = "vault"
          annotations = {
            "eks.amazonaws.com/role-arn" = module.vault_irsa.iam_role_arn
          }
        }

        extraEnvironmentVars = {
          AWS_REGION           = var.aws_region
          VAULT_CACERT         = "/vault/userconfig/vault-tls/vault.ca"
          VAULT_TLSCERT        = "/vault/userconfig/vault-tls/vault.crt"
          VAULT_TLSKEY         = "/vault/userconfig/vault-tls/vault.key"
        }

        volumes = [
          {
            name = "userconfig-vault-tls"
            secret = {
              secretName  = kubernetes_secret.vault_tls.metadata[0].name
              defaultMode = 420
            }
          }
        ]

        volumeMounts = [
          {
            name      = "userconfig-vault-tls"
            mountPath = "/vault/userconfig/vault-tls"
            readOnly  = true
          }
        ]

        ha = {
          enabled  = true
          replicas = 3
          
          raft = {
            enabled   = true
            setNodeId = true
            
            config = <<-EOT
              ui = true
              
              listener "tcp" {
                tls_disable = 0
                address = "[::]:8200"
                cluster_address = "[::]:8201"
                tls_cert_file = "/vault/userconfig/vault-tls/vault.crt"
                tls_key_file = "/vault/userconfig/vault-tls/vault.key"
                tls_client_ca_file = "/vault/userconfig/vault-tls/vault.ca"
              }

              storage "raft" {
               path = "/vault/data"
               retry_join { 
                leader_api_addr = "https://vault-0.vault-internal:8200"
                leader_ca_cert_file = "/vault/userconfig/vault-tls/vault.ca"
                leader_client_cert_file = "/vault/userconfig/vault-tls/vault.crt"
                leader_client_key_file = "/vault/userconfig/vault-tls/vault.key"
               }
               retry_join { 
                leader_api_addr = "https://vault-1.vault-internal:8200"
                leader_ca_cert_file = "/vault/userconfig/vault-tls/vault.ca"
                leader_client_cert_file = "/vault/userconfig/vault-tls/vault.crt"
                leader_client_key_file = "/vault/userconfig/vault-tls/vault.key"
               }
               retry_join { 
                leader_api_addr = "https://vault-2.vault-internal:8200"
                leader_ca_cert_file = "/vault/userconfig/vault-tls/vault.ca"
                leader_client_cert_file = "/vault/userconfig/vault-tls/vault.crt"
                leader_client_key_file = "/vault/userconfig/vault-tls/vault.key"
               }
               retry_join { 
                leader_api_addr = "https://vault-3.vault-internal:8200"
                leader_ca_cert_file = "/vault/userconfig/vault-tls/vault.ca"
                leader_client_cert_file = "/vault/userconfig/vault-tls/vault.crt"
                leader_client_key_file = "/vault/userconfig/vault-tls/vault.key"
               }
               retry_join { 
                leader_api_addr = "https://vault-4.vault-internal:8200"
                leader_ca_cert_file = "/vault/userconfig/vault-tls/vault.ca"
                leader_client_cert_file = "/vault/userconfig/vault-tls/vault.crt"
                leader_client_key_file = "/vault/userconfig/vault-tls/vault.key"
               }
               retry_join { 
                leader_api_addr = "https://vault-5.vault-internal:8200"
                leader_ca_cert_file = "/vault/userconfig/vault-tls/vault.ca"
                leader_client_cert_file = "/vault/userconfig/vault-tls/vault.crt"
                leader_client_key_file = "/vault/userconfig/vault-tls/vault.key"
               }
               retry_join { 
                leader_api_addr = "https://vault-6.vault-internal:8200"
                leader_ca_cert_file = "/vault/userconfig/vault-tls/vault.ca"
                leader_client_cert_file = "/vault/userconfig/vault-tls/vault.crt"
                leader_client_key_file = "/vault/userconfig/vault-tls/vault.key"
               }
            }

              seal "awskms" {
                region     = "${var.aws_region}"
                kms_key_id = "${aws_kms_key.vault.id}"
              }

              service_registration "kubernetes" {}
            EOT
          }
        }

        dataStorage = {
          enabled      = true
          size         = "10Gi"
          storageClass = kubernetes_storage_class.vault_ebs.metadata[0].name
          accessMode   = "ReadWriteOnce"
        }

        auditStorage = {
          enabled      = true
          size         = "10Gi"
          storageClass = kubernetes_storage_class.vault_ebs.metadata[0].name
          accessMode   = "ReadWriteOnce"
        }

        resources = {
          requests = {
            memory = "256Mi"
            cpu    = "250m"
          }
          limits = {
            memory = "512Mi"
            cpu    = "500m"
          }
        }
      }

      ui = {
        enabled = true
        serviceType = "LoadBalancer"
      }
    })
  ]

  depends_on = [
    kubernetes_namespace.vault,
    kubernetes_secret.vault_license,
    kubernetes_secret.vault_tls,
    kubernetes_storage_class.vault_ebs,
    module.ebs_csi_irsa
  ]
}

