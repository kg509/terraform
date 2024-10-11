module "vars" {
  source = "../vars"
}

resource "helm_release" "argocd" {
  # depends_on = [
  #   aws_iam_role.argocd_reposerver_role,
  #   aws_iam_role_policy_attachment.amazon_eks_worker_node_policy
  # ]

  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  # version          = "" # 버전 확인하기
  namespace        = module.vars.argocd_namespace
  create_namespace = true

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  # set {
  #   name  = "server.serviceAccount.create"
  #   value = "true"
  # }

  # set {
  #   name  = "server.serviceAccount.name"
  #   value = "argocd-repo-server"
  # }

  # set {
  #   name  = "server.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
  #   value = aws_iam_role.argocd_reposerver_role.arn
  # }
  # 서비스 어카운트 매핑 어케했는지 확인하기
  # 어노테이션 어느단계 했는지 물어보기
  # 아래 처럼 토큰 set블록 어떤지 물어보기
  # set {
  #   name  = "server.serviceAccount.automountServiceAccountToken"
  #   value = "module.vars.token"
  # }
}

# https://spacelift.io/blog/argocd-terraform
# https://argo-cd.readthedocs.io/en/stable/user-guide/best_practices/
# https://github.com/argoproj/argo-helm/blob/main/charts/argo-cd/templates/argocd-server/serviceaccount.yaml
# chart: argo-cd-7.5.2 APP VERSION v2.12.3
