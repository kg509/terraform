module "vars" {
  source = "../vars"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name            = module.vars.cluster_name
  cidr            = "172.28.0.0/16"
  azs             = ["ap-northeast-2a", "ap-northeast-2c"]
  private_subnets = ["172.28.11.0/24", "172.28.31.0/24", "172.28.21.0/24", "172.28.41.0/24"]
  public_subnets  = ["172.28.10.0/24", "172.28.30.0/24"]

  # Kubernetes에서 AWS ELB를 사용하여 서비스의 로드밸런싱 자동화 설정
  public_subnet_tags = {
    # 인터넷에 노출된 ELB
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    # VPC 내에서만 접근 가능한 ELB
    "kubernetes.io/role/internal-elb" = 1

    # Karpenter 디스커버리를 위한 태그 추가
    "karpenter.sh/discovery" = module.vars.cluster_name
  }
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  # EKS Cluster Setting
  cluster_name    = module.vars.cluster_name
  cluster_version = module.vars.cluster_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]

  # EKS Worker Node 정의 ( ManagedNode방식: Launch Template 자동 구성 )
  eks_managed_node_groups = {
    initial = {
      instance_types         = [module.vars.cluster_workernode_type]
      min_size               = 2
      max_size               = 10
      desired_size           = 2
      vpc_security_group_ids = [module.add_node_sg.security_group_id]
    }
  }

  # public-subnet(bastion)과 API와 통신하기 위해 설정(443)
  cluster_additional_security_group_ids = [module.add_cluster_sg.security_group_id]
  cluster_endpoint_public_access        = true

  # AWS EKS 클러스터를 생성할 때, 
  # 해당 클러스터를 생성한 IAM 사용자에게 관리자 권한을 부여하는 옵션
  # K8s ConfigMap Object "aws_auth" 구성
  # 구성 후 명령어로 확인 가능, kubectl -n kube-system get configmap aws-auth -o yaml
  enable_cluster_creator_admin_permissions = true
  node_security_group_tags = {
    "karpenter.sh/discovery" = module.vars.cluster_name
  }
}
