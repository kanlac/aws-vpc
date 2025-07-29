module "vpc" {
  source = "./modules/vpc"

  private_subnet_offset        = 10
  enable_availability_zone_num = var.zone_num
}

module "elasticache" {
  source  = "foss-cafe/elasticache/aws"
  version = "1.0.2"

  name                          = "redis"
  replication_group_description = "Redis"
  family                        = "redis6.x"

  vpc_id                  = module.vpc.vpc_id
  subnet_ids              = module.vpc.private_subnet_ids
  allowed_security_groups = []
  allowed_cidr_blocks     = ["10.0.0.0/16"]
  cluster_size            = var.zone_num
  node_type               = "cache.t3.micro"
  apply_immediately       = true
}