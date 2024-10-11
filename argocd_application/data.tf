data "aws_eks_cluster" "cluster" {
  name = module.vars.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.aws_eks_cluster.cluster.name
}

data "kubernetes_service" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = module.vars.argocd_namespace
  }
}

data "kubernetes_secret" "argocd_secret" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = module.vars.argocd_namespace
  }
}