resource "kubernetes_config_map_v1_data" "aws_auth_update" {
  depends_on = [module.eks]

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = <<YAML
${trimspace(data.kubernetes_config_map.aws_auth.data["mapRoles"])}
- groups:
  - system:bootstrappers
  - system:nodes
  rolearn: arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/KarpenterNodeRole-${module.vars.cluster_name}
  username: system:node:{{EC2PrivateDNSName}}
YAML
  }

  force = true
}

resource "kubernetes_config_map" "db_config" {
  depends_on = [module.eks, module.db]

  metadata {
    name      = "db-config"
    namespace = "default"
  }

  data = {
    DB_ENDPOINT = module.db.db_instance_endpoint
  }
}
