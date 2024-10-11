output "provider_profile" {
  value = var.global_settings["provider_profile"]
}

output "provider_region" {
  value = var.global_settings["provider_region"]
}

output "aws_partition" {
  value = var.global_settings["aws_partition"]
}

output "aws_region" {
  value = var.global_settings["aws_region"]
}

output "bastion_type" {
  value = var.global_settings["bastion_type"]
}

output "nat_type" {
  value = var.global_settings["nat_type"]
}

output "cluster_version" {
  value = var.global_settings["cluster_version"]
}

output "cluster_name" {
  value = var.global_settings["cluster_name"]
}

output "cluster_workernode_type" {
  value = var.global_settings["cluster_workernode_type"]
}

output "karpenter_version" {
  value = var.global_settings["karpenter_version"]
}

output "karpenter_namespace" {
  value = var.global_settings["karpenter_namespace"]
}

output "loki_namespace" {
  value = var.global_settings["loki_namespace"]
}

output "argocd_namespace" {
  value = var.global_settings["argocd_namespace"]
}

output "argocd_app_name" {
  value = var.global_settings["argocd_app_name"]
}

# 추후 필요시 추가
# output "argocd_version" {
#   value = var.global_settings["argocd_version"]
# }

output "ecr_repo_name" {
  value = var.global_settings["ecr_repo_name"]
}

output "github_app_repo_name" {
  value = var.global_settings["github_app_repo_name"]
}

output "github_manifest_repo_name" {
  value = var.global_settings["github_manifest_repo_name"]
}

output "argocd_server_port" {
  value = var.global_settings["argocd_server_port"]
}

output "db_name" {
  value = var.global_settings["db_name"]
}

output "db_identifier" {
  value = var.global_settings["db_identifier"]
}

output "db_engine" {
  value = var.global_settings["db_engine"]
}

output "db_engine_version" {
  value = var.global_settings["db_engine_version"]
}

output "db_instance_class" {
  value = var.global_settings["db_instance_class"]
}

output "db_allocated_storage" {
  value = tonumber(var.global_settings["db_allocated_storage"])
}

output "db_port" {
  value = var.global_settings["db_port"]
}

output "db_sg_ingress_rule" {
  value = var.global_settings["db_sg_ingress_rule"]
}