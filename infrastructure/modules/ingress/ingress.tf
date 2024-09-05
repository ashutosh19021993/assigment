# modules/ingress_controller/main.tf

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "nginx-ingress"
  #version    = "3.32.0" # Adjust to the latest version if needed

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  #   depends_on = [
  #     module.cluster.cluster_endpoint
  #   ]
}
