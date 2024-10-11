output "bastion_public_ip" {
  value = data.aws_instance.bastion.public_ip
}

output "oidc_provider_arn" {
  value = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

output "argocd_admin_password" {
  value = data.kubernetes_secret.argocd_secret.data["password"]
  sensitive = true
}

output "argocd_server_address" {
  value = "${coalesce(
    data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname,
    data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].ip
  )}:${module.vars.argocd_server_port}"
}