# modules/eks_addons/main.tf

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = var.cluster_name
  addon_name   = "vpc-cni"
  #addon_version = var.vpc_cni_version

  tags = {
    Name = "vpc-cni-addon"
  }
}

resource "aws_eks_addon" "core_dns" {
  cluster_name = var.cluster_name
  addon_name   = "coredns"
  #addon_version = var.core_dns_version

  tags = {
    Name = "core-dns-addon"
  }
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = var.cluster_name
  addon_name   = "kube-proxy"
  #addon_version = var.kube_proxy_version

  tags = {
    Name = "kube-proxy-addon"
  }
}
