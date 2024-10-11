module "vars" {
  source = "../vars"
}

resource "argocd_repository" "github_private_repo" {
  repo     = "https://github.com/${var.git_owner}/${module.vars.github_manifest_repo_name}.git"
  username = var.git_name
  password = var.git_token
}

resource "argocd_application" "my_app" {
  metadata {
    name      = module.vars.argocd_app_name
    namespace = module.vars.argocd_namespace
  }

  spec {
    project = "default"

    source {
      repo_url        = argocd_repository.github_private_repo.repo # GitHub Private Repository URL
      target_revision = "main"                                     # GitHub 브랜치 이름 (main)
      path            = "./k8s"                                    # 매니페스트 파일이 있는 경로
    }

    destination {
      server    = "https://kubernetes.default.svc" # EKS 클러스터 내부 Kubernetes API 서버 주소
      namespace = "default"                        # 배포할 네임스페이스
    }

    sync_policy {
      automated {
        prune     = true # 기존 리소스를 자동으로 정리
        self_heal = true # 변경 사항이 있을 때 자동으로 복구
      }
    }
  }
}