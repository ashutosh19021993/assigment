# modules/cluster/eks.tf

# Define the IAM role for EKS
resource "aws_iam_role" "this" {
  name = "${var.cluster_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = [
            "eks-fargate-pods.amazonaws.com",
            "eks.amazonaws.com",
          ]
        }
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", # For accessing ECR images
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",          # Essential for EKS worker nodes
    "arn:aws:iam::aws:policy/AmazonEC2ContainerServiceforEC2Role"
  ]
}

# Attach the necessary IAM policies to the role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Define the EKS cluster
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.this.arn
  version  = "1.26"

  vpc_config {
    subnet_ids              = var.subnets
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

# Outputs
output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "cluster_role_arn" {
  value = aws_iam_role.this.arn
}
