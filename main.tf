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
  subnet_id = module.network.private_subnet_ids[0]
  key_name = var.key_name
  vpc_id = module.network.aws_vpc_id
  alb_sg_id = module.alb.alb_sg_id
}

#==========================================================


module "alb" {
  source = "./modules/alb"
  vpc_id = module.network.aws_vpc_id
  subnets = module.network.public_subnet_ids
  
}

module "asg" {
  source = "./modules/asg"
  ami = var.ami
  target_group_arn = [ module.alb.target_group_arn ]
  e2_sg_id = [module.ec2.e2_sg_id]
  private_subnet_ids = module.network.private_subnet_ids
  
}

# resource "aws_lb_target_group_attachment" "tg_attach" {
#   target_group_arn = aws_lb_target_group.tg.arn
#   target_id        = module.ec2.instance_id               # Manual attachment of ec2 instance
#   port             = 80
# }



#================================================== ASG below=======================================
