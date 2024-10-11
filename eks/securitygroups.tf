module "add_cluster_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name            = "add-cluster-sg"
  vpc_id          = module.vpc.vpc_id
  use_name_prefix = false

  ingress_with_cidr_blocks = [
    {
      rule        = "https-443-tcp"
      cidr_blocks = module.vpc.vpc_cidr_block
    }
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "add_node_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name            = "add-node-sg"
  vpc_id          = module.vpc.vpc_id
  use_name_prefix = false

  ingress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = module.vpc.vpc_cidr_block
    }
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    "karpenter.sh/discovery" = module.vars.cluster_name
  }
}

module "bastion_host_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name            = "bastion-host-sg"
  vpc_id          = module.vpc.vpc_id
  use_name_prefix = false

  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule        = "all-icmp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "nat_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name            = "nat-sg"
  vpc_id          = module.vpc.vpc_id
  use_name_prefix = false

  ingress_with_cidr_blocks = [
    for cidr in module.vpc.private_subnets_cidr_blocks : {
      rule        = "all-all"
      cidr_blocks = cidr
    }
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "db_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "db-sg"
  description = "Security group for DB with MySQL port open within VPC"
  vpc_id      = module.vpc.vpc_id
  ingress_with_cidr_blocks = [
    {
      rule        = module.vars.db_sg_ingress_rule
      cidr_blocks = module.vpc.vpc_cidr_block
    }
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}
