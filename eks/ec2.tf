module "bastion_host" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  depends_on                  = [module.eks, module.db]
  ami                         = data.aws_ami.al2023.id
  name                        = "bastion-host"
  associate_public_ip_address = true
  instance_type               = module.vars.bastion_type
  key_name                    = var.bastion_key_name
  monitoring                  = true
  vpc_security_group_ids      = [module.bastion_host_sg.security_group_id]
  subnet_id                   = module.vpc.public_subnets[0]

  user_data = templatefile("${path.module}/userdata.sh.tpl",
    {
      ACCESS_KEY   = var.access_key
      SECRET_KEY   = var.secret_key
      REGION       = module.vars.provider_region
      CLUSTER_NAME = module.vars.cluster_name
      PROFILE_NAME = module.vars.provider_profile

      DB_NAME     = module.vars.db_name
      DB_USERNAME = var.db_username
      DB_PASSWORD = var.db_password
      DB_ENDPOINT = module.db.db_instance_endpoint
      DB_PORT     = module.vars.db_port
    }
  )
}

module "nat_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  ami                         = "ami-01ad0c7a4930f0e43"
  name                        = "nat-instance"
  associate_public_ip_address = true
  instance_type               = module.vars.nat_type
  source_dest_check           = false
  vpc_security_group_ids      = [module.nat_sg.security_group_id]
  subnet_id                   = module.vpc.public_subnets[1]
}

# Private Subnet Routing Table ( dest: NAT Instance ENI )
resource "aws_route" "private_subnet" {
  count                  = length(module.vpc.private_route_table_ids)
  route_table_id         = module.vpc.private_route_table_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = module.nat_instance.primary_network_interface_id
}