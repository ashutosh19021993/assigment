# modules/ingress_controller/main.tf

# resource "kubernetes_namespace" "microservices" {
#   metadata {
#     name = "nginx"
#   }
# }

# resource "helm_repository" "nginx" {
#   name = "ingress-nginx"
#   url  = "https://kubernetes.github.io/ingress-nginx"
# }

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.11.2" # Adjust to the latest version if needed
  #namespace  = "nginx"

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }
  set {
    name  = "controller.ingressClassName"
    value = "nginx" # Define the ingress class name
  }

}
