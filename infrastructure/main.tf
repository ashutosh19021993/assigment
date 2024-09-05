terraform {
  # required_version = "~> 1.0.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.41.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.24.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.6.0"
    }
  }

}

provider "aws" {
  region = "ap-northeast-3"
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
  node_role_arn   = aws_iam_role.eks_node_role.arn
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


resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
  ]
}

resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerServiceforEC2Role",
  ]
}

module "ingress" {
  source     = "./modules/ingress"
  depends_on = [module.cluster]
}

module "java-app" {
  source     = "./modules/java-app"
  depends_on = [module.ingress]
}
output "cluster_endpoint" {
  value = module.cluster.cluster_endpoint
}


output "cluster_name" {
  value = module.cluster.cluster_name
}