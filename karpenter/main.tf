module "vars" {
  source = "../vars"
}

resource "helm_release" "karpenter_controller" {
  depends_on = [
    aws_iam_role.karpenter_controller_role,
    aws_iam_role_policy.karpenter_controller_policy,
    aws_iam_role.karpenter_node_role,
    aws_iam_role_policy_attachment.amazon_ecr_read_only,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.amazon_ssm_managed_instance_core
  ]

  name             = "karpenter"
  repository       = "oci://public.ecr.aws/karpenter"
  chart            = "karpenter"
  version          = module.vars.karpenter_version
  namespace        = module.vars.karpenter_namespace
  create_namespace = true

  set {
    name  = "settings.clusterName"
    value = module.vars.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.karpenter_controller_role.arn
  }

  # set {
  #   name = "serviceAccount.name"
  #   value = "karpenter"
  # }

  # set {
  #   name  = "controller.resources.requests.cpu"
  #   value = "1"
  # }

  # set {
  #   name  = "controller.resources.requests.memory"
  #   value = "1Gi"
  # }

  # set {
  #   name  = "controller.resources.limits.cpu"
  #   value = "1"
  # }

  # set {
  #   name  = "controller.resources.limits.memory"
  #   value = "1Gi"
  # }
}
