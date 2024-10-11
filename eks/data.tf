data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster_auth" "cluster" {
  depends_on = [module.eks]
  name       = module.eks.cluster_name
}

data "kubernetes_config_map" "aws_auth" {
  depends_on = [module.eks]

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
}