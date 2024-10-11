module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = module.vars.db_identifier

  # 기본값 : true,  Secrets Manager에서 설정한 비밀번호를 사용해야함
  # false, 입력한 비밀번호 사용
  manage_master_user_password = false

  engine            = module.vars.db_engine
  engine_version    = module.vars.db_engine_version
  instance_class    = module.vars.db_instance_class
  allocated_storage = module.vars.db_allocated_storage

  db_name  = module.vars.db_name
  username = var.db_username
  password = var.db_password
  port     = module.vars.db_port

  vpc_security_group_ids = [module.db_sg.security_group_id]

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids = [
    module.vpc.private_subnets[2],
    module.vpc.private_subnets[3]
  ]

  # DB parameter group
  create_db_parameter_group = false

  # DB option group
  create_db_option_group = false

  # Database Deletion Protection
  # deletion_protection = true

  # RDS 삭제 시 백업 하지마
  skip_final_snapshot = true
  # 변경 사항 즉시 적용
  apply_immediately = true
}