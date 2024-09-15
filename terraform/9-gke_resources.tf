resource "google_service_account" "cert_manager" {
  account_id   = "cert-manager"
  display_name = "Cert Manager Service Account"
}

# Cert Manager Installation
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }
  set {
    name  = "ingressShim.defaultIssuerName"
    value = "letsencrypt-prod"
  }
  set {
    name  = "ingressShim.defaultIssuerKind"
    value = "ClusterIssuer"
  }
}

# Create a ClusterIssuer for Let's Encrypt
# resource "kubernetes_manifest" "letsencrypt_prod_issuer" {
#   # provider = kubernetes
#   manifest = {
#     apiVersion = "cert-manager.io/v1"
#     kind       = "ClusterIssuer"
#     metadata = {
#       name = "letsencrypt-prod"
#     }
#     spec = {
#       acme = {
#         server = "https://acme-v02.api.letsencrypt.org/directory"
#         email  = "omarahmed9113@gmail.com"  # Replace with your email
#         privateKeySecretRef = {
#           name = "letsencrypt-prod"
#         }
#         solvers = [{
#           http01 = {
#             ingress = {
#               class = "nginx"
#             }
#           }
#         }]
#       }
#     }
#   }
#   # depends_on = [google_container_cluster.primary]

# }

# External Secrets Operator Installation
resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  namespace  = "external-secrets"
  chart      = "external-secrets"
  repository = "https://charts.external-secrets.io"
  version    = "0.6.1"

  create_namespace = true
}


# NGINX Ingress Controller Installation
resource "helm_release" "ingress" {
  name             = "ingress-nginx"
  create_namespace = true
  namespace        = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  # version          = "4.0.5"
  timeout          = 300
  atomic           = true

#   values = [
#     <<EOF
# controller:
#   podSecurityContext:
#     runAsNonRoot: true
# service:
#   enabled: true
#   annotations:
#     service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
#   enableHttp: true
#   enableHttps: true
# EOF
#   ]

}

# Get the Kubernetes Service for Ingress
data "kubernetes_service_v1" "ingress_service" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
  depends_on = [ helm_release.ingress ]
}

# Fetch GCP DNS Managed Zone
data "google_dns_managed_zone" "default" {
  name = "enkidudev-website-zone"  # Replace with your GCP managed zone name
}

# Create CNAME Record in Google Cloud DNS
resource "google_dns_record_set" "ingress_record" {
  managed_zone = data.google_dns_managed_zone.default.name
  name         = "app.enkidudev.website."  # Ensure the domain name ends with a dot
  type         = "A"
  ttl          = 300
  rrdatas      = [
    data.kubernetes_service_v1.ingress_service.status[0].load_balancer[0].ingress[0].ip
  ]
}


# ArgoCD Installation
resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = "argocd"
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  version    = "4.0.0"  # Replace with the latest version

  create_namespace = true
}