variable "global_settings" {
  type = map(string)
  default = {
    provider_profile        = "admin"
    provider_region         = "ap-northeast-2"

    aws_partition           = "aws"
    aws_region              = "ap-northeast-2"

    bastion_type            = "t2.micro"
    nat_type                = "t2.micro"

    db_name                 = "care"
    db_identifier           = "database-1"
    db_engine               = "mariadb"
    db_engine_version       = "10.11"
    db_instance_class       = "db.t3.micro"
    db_allocated_storage    = "10"
    db_port                 = "3306"
    db_sg_ingress_rule      = "mysql-tcp"

    cluster_version         = "1.30"
    cluster_name            = "my-eks"
    cluster_workernode_type = "t3.medium"

    karpenter_version       = "1.0.1"
    karpenter_namespace     = "karpenter"

    loki_namespace          = "loki-stack"
    
    argocd_namespace        = "argocd"
    argocd_app_name         = "my-app"
    argocd_server_port      = "80"
    # argocd_version = "버전대입"  # 추후 대입할 항목

    ecr_repo_name             = "my-app-repo"
    github_app_repo_name      = "app"
    github_manifest_repo_name = "manifest"

  }
}