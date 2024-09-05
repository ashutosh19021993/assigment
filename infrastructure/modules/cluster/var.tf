variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "subnets" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID where the EKS cluster is deployed"
  type        = string
}