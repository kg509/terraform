terraform {
  required_providers {
    aws = {
      version = "~> 5.0"
      source  = "hashicorp/aws"
    }
    argocd = {
      source  = "oboukili/argocd"
      version = "6.1.1"
    }
  }
}

provider "aws" {
  profile = module.vars.provider_profile
  region  = module.vars.provider_region
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
}

provider "argocd" {
  server_addr = "${coalesce(
    data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname,
    data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].ip
  )}:${module.vars.argocd_server_port}"
  username = "admin"
  password = data.kubernetes_secret.argocd_secret.data["password"]
  insecure = true
}
