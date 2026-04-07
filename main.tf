provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "terraform-state-nikhil-99"   
    key            = "prod/terraform.tfstate"      
    region         = "us-east-1"                   
    dynamodb_table = "terraform-locks"             
  }
}

module "network" {
  source = "./modules/vpc"
  cidr_block = var.cidr_block
  private_subnet = var.private_subnet
  public_subnet = var.public_subnet
}

module "ec2" {
  source = "./modules/ec2"
  ami = var.ami
  instance_type = var.instance_type
  subnet_id = module.network.public_subnet_ids[0]
  key_name = var.key_name
  vpc_id = module.network.aws_vpc_id
  
}
