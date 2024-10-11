data "aws_eks_cluster" "cluster" {
  name = module.vars.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.aws_eks_cluster.cluster.name
}
