terraform {
  # required_version = "~> 1.0.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.41.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.1"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.2.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.24.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.9.0"
    }

  }

}

provider "aws" {
  region = "ap-northeast-3"
}
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config" # Adjust if necessary
  }
}
module "vpc" {
  source          = "./modules/vpc"
  name            = "eks-vpc"
  cidr_block      = "10.0.0.0/16"
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
}

module "cluster" {
  source       = "./modules/cluster"
  cluster_name = "test"
  vpc_id       = module.vpc.vpc_id
  subnets      = module.vpc.private_subnets
  depends_on   = [module.vpc]

}

module "eks_node_group" {
  source          = "./modules/eks_node_group"
  cluster_name    = module.cluster.cluster_name
  node_group_name = "worker-group"
  node_role_arn   = module.eks_node_group.node_role_arn
  subnet_ids      = module.vpc.private_subnets
  desired_size    = 2
  max_size        = 3
  min_size        = 1
  instance_types  = ["t3.medium"]
  depends_on = [
    module.cluster
  ]
}

module "eks_addons" {
  source             = "./modules/eks_addons"
  cluster_name       = module.cluster.cluster_name
  vpc_cni_version    = "latest"
  core_dns_version   = "latest"
  kube_proxy_version = "latest"
}


module "ingress" {
  source     = "./modules/ingress"
  depends_on = [module.cluster, module.eks_node_group]
}

module "java-app" {
  source     = "./modules/java-app"
  depends_on = [module.ingress]
}
output "cluster_endpoint" {
  value = module.cluster.cluster_endpoint
}

output "eks_node_group_role_arn" {
  value = module.eks_node_group.node_role_arn
}

output "cluster_name" {
  value = module.cluster.cluster_name
}