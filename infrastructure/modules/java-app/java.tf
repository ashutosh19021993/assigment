# Create the namespace for the microservices
resource "kubernetes_namespace" "microservices" {
  metadata {
    name = "microservices"
  }
}

# Define the deployment for the Java microservice
resource "kubernetes_deployment" "java_microservice" {
  metadata {
    name      = "java-deployment"
    namespace = kubernetes_namespace.microservices.metadata[0].name
    labels = {
      app = "java-microservice"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "java-microservice"
      }
    }

    template {
      metadata {
        labels = {
          app = "java-microservice"
        }
      }

      spec {
        container {
          name  = "java-container"
          image = "amazoncorretto:11-alpine" # Java image
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

# Define the service to expose the Java microservice
resource "kubernetes_service" "java_microservice" {
  metadata {
    name      = "java-microservice-svc"
    namespace = kubernetes_namespace.microservices.metadata[0].name
  }

  spec {
    selector = {
      app = "java-microservice"
    }

    port {
      port        = 80
      target_port = 8080
    }

    type = "ClusterIP"
  }
}

# Define the ingress resource to route traffic to the service
resource "kubernetes_ingress" "java_microservice" {
  metadata {
    name      = "java-ingress"
    namespace = kubernetes_namespace.microservices.metadata[0].name
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      host = "java-microservice.example.com" # Replace with your domain

      http {
        path {
          path = "/"
          backend {
            service_name = kubernetes_service.java_microservice.metadata[0].name
            service_port = 80
          }
        }
      }
    }
  }
}


