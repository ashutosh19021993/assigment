# modules/eks_node_group/variables.tf

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "node_group_name" {
  description = "The name of the node group"
  type        = string
}

variable "node_role_arn" {
  description = "The ARN of the IAM role for the node group"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the node group"
  type        = list(string)
}

variable "desired_size" {
  description = "Desired number of nodes in the node group"
  type        = number
}

variable "max_size" {
  description = "Maximum number of nodes in the node group"
  type        = number
}

variable "min_size" {
  description = "Minimum number of nodes in the node group"
  type        = number
}

variable "instance_types" {
  description = "List of instance types for the node group"
  type        = list(string)
}

# variable "node_role_arn" {
#   description = "The ARN of the IAM role for the node group."
#   type        = string
# }