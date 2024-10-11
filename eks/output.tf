output "bastion_ip" {
  value       = module.bastion_host.public_ip
  description = "bastion-host public IP"
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}
