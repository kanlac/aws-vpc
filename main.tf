module "vpc" {
  source = "./modules/vpc"

  private_subnet_offset = 10
}