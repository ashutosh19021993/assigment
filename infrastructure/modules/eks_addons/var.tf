# modules/eks_addons/variables.tf

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "vpc_cni_version" {
  description = "The version of the VPC CNI add-on"
  type        = string
}

variable "core_dns_version" {
  description = "The version of the CoreDNS add-on"
  type        = string
}

variable "kube_proxy_version" {
  description = "The version of the kube-proxy add-on"
  type        = string
}
