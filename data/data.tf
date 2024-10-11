data "aws_eks_cluster" "cluster" {
  name = module.vars.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.aws_eks_cluster.cluster.name
}

data "aws_instance" "bastion" {
  filter {
    name   = "tag:Name"
    values = ["bastion-host"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}

data "kubernetes_secret" "argocd_secret" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = module.vars.argocd_namespace
  }
}

data "kubernetes_service" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = module.vars.argocd_namespace
  }
}