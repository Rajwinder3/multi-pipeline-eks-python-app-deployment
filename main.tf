module "vpc" {
  source = "./modules/vpc"
}

module "rds"{
  source = "./modules/rds"
  username = var.db_username
  password = var.db_password
  private_subnet = module.vpc.private_subnet_ids
  security_group = [module.vpc.sg_private]
}

module "eks" {
  source = "./modules/eks"
  eks_subnet_ids = module.vpc.private_subnet_ids
  desired_size = var.desired_size
  max_size = var.max_size
  min_size = var.min_size
  # node_group_sg_id = [module.vpc.sg_public]
}