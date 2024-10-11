########################################
# Karpenter Controller Role
########################################

resource "aws_iam_role" "karpenter_controller_role" {
  name = "KarpenterControllerRole-${module.vars.cluster_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.oidc.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(data.aws_iam_openid_connect_provider.oidc.url, "https://", "")}:aud" = "sts.amazonaws.com",
            "${replace(data.aws_iam_openid_connect_provider.oidc.url, "https://", "")}:sub" = "system:serviceaccount:${module.vars.karpenter_namespace}:karpenter"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "karpenter_controller_policy" {
  name = "KarpenterControllerPolicy-${module.vars.cluster_name}"
  role = aws_iam_role.karpenter_controller_role.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "Karpenter",
        Effect = "Allow",
        Action = [
          "ssm:GetParameter",
          "ec2:DescribeImages",
          "ec2:RunInstances",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeAvailabilityZones",
          "ec2:DeleteLaunchTemplate",
          "ec2:CreateTags",
          "ec2:CreateLaunchTemplate",
          "ec2:CreateFleet",
          "ec2:DescribeSpotPriceHistory",
          "pricing:GetProducts"
        ],
        Resource = "*"
      },
      {
        Sid    = "ConditionalEC2Termination",
        Effect = "Allow",
        Action = "ec2:TerminateInstances",
        Condition = {
          StringLike = {
            "ec2:ResourceTag/karpenter.sh/nodepool" = "*"
          }
        },
        Resource = "*"
      },
      {
        Sid      = "PassNodeIAMRole",
        Effect   = "Allow",
        Action   = "iam:PassRole",
        Resource = "arn:${module.vars.aws_partition}:iam::${data.aws_caller_identity.current.account_id}:role/KarpenterNodeRole-${module.vars.cluster_name}"
      },
      {
        Sid      = "EKSClusterEndpointLookup",
        Effect   = "Allow",
        Action   = "eks:DescribeCluster",
        Resource = "arn:${module.vars.aws_partition}:eks:${module.vars.aws_region}:${data.aws_caller_identity.current.account_id}:cluster/${module.vars.cluster_name}"
      },
      {
        Sid      = "AllowScopedInstanceProfileCreationActions",
        Effect   = "Allow",
        Resource = "*",
        Action = [
          "iam:CreateInstanceProfile"
        ],
        Condition = {
          StringEquals = {
            "aws:RequestTag/kubernetes.io/cluster/${module.vars.cluster_name}" = "owned",
            "aws:RequestTag/topology.kubernetes.io/region"                     = module.vars.aws_region
          },
          StringLike = {
            "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass" = "*"
          }
        }
      },
      {
        Sid      = "AllowScopedInstanceProfileTagActions",
        Effect   = "Allow",
        Resource = "*",
        Action = [
          "iam:TagInstanceProfile"
        ],
        Condition = {
          StringEquals = {
            "aws:ResourceTag/kubernetes.io/cluster/${module.vars.cluster_name}" = "owned",
            "aws:ResourceTag/topology.kubernetes.io/region"                     = module.vars.aws_region,
            "aws:RequestTag/kubernetes.io/cluster/${module.vars.cluster_name}"  = "owned",
            "aws:RequestTag/topology.kubernetes.io/region"                      = module.vars.aws_region
          },
          StringLike = {
            "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass" = "*",
            "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass"  = "*"
          }
        }
      },
      {
        Sid      = "AllowScopedInstanceProfileActions",
        Effect   = "Allow",
        Resource = "*",
        Action = [
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:DeleteInstanceProfile"
        ],
        Condition = {
          StringEquals = {
            "aws:ResourceTag/kubernetes.io/cluster/${module.vars.cluster_name}" = "owned",
            "aws:ResourceTag/topology.kubernetes.io/region"                     = module.vars.aws_region
          },
          StringLike = {
            "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass" = "*"
          }
        }
      },
      {
        Sid      = "AllowInstanceProfileReadActions",
        Effect   = "Allow",
        Resource = "*",
        Action   = "iam:GetInstanceProfile"
      }
    ]
  })
}

#########################################
# Karpenter Node Role
#########################################

resource "aws_iam_role" "karpenter_node_role" {
  name = "KarpenterNodeRole-${module.vars.cluster_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
  role       = aws_iam_role.karpenter_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy" {
  role       = aws_iam_role.karpenter_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "amazon_ecr_read_only" {
  role       = aws_iam_role.karpenter_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "amazon_ssm_managed_instance_core" {
  role       = aws_iam_role.karpenter_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}