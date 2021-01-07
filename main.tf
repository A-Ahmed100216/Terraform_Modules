# Which cloud provider is required?
# AWS as this is where we have created our AMIs.

provider "aws" {
    region = var.region

}

module "myip" {
  source  = "4ops/myip/http"
  version = "1.0.0"
}


module "vpc" {
  source = "./modules/vpc"
}

module "app" {
  source = "./modules/app"
  VPC-Aminah = module.vpc.vpc_id
  igw-Aminah = module.vpc.igw_id
  app-ami = var.app_ami
  key-name = var.key_name
  db_public_ip = module.db.db_ip
  my_ip = module.myip.address
}

module "db" {
  source = "./modules/db"
  VPC-Aminah =  module.vpc.vpc_id
  igw-Aminah =  module.vpc.igw_id
  db-ami = var.db_ami
  key-name = var.key_name
  sg_app_id = module.app.sg_app_id
  public_subnet_ip = module.app.public_subnet_ip
  public_subnet_id = module.app.public_subnet_id
  my_ip = module.myip.address

}
