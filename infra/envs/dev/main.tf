module "network" {
  source = "../../modules/network"

  name                 = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

module "ecs" {
  source = "../../modules/ecs"

  name               = var.environment
  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
  desired_count      = var.ecs_desired_count

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

module "rds" {
  source = "../../modules/rds"

  name                  = var.environment
  vpc_id                = module.network.vpc_id
  private_subnet_ids    = module.network.private_subnet_ids
  ecs_security_group_id = module.ecs.ecs_security_group_id

  instance_class          = var.rds_instance_class
  allocated_storage       = var.rds_allocated_storage
  backup_retention_period = var.rds_backup_retention_period
  deletion_protection     = var.rds_deletion_protection

  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}