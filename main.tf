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
  certificate_arn = aws_acm_certificate.cert.arn
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
#===============================================RDS configuration====================================================
resource "aws_security_group" "rds_sg" {
  name   = "rds-sg"

  vpc_id = module.network.aws_vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [module.ec2.e2_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "db_subnet" {
  name       = "db-subnet-group"
  subnet_ids = module.network.private_subnet_ids

  tags = {
    Name = "db-subnet-group"
  }

}

resource "aws_db_instance" "db" {
  identifier              = "app-db"
  allocated_storage       = 20
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  db_name = "appdb"
  username                = "admin"
  # password                = "Admin12345!"
  manage_master_user_password = true
  
  db_subnet_group_name    = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  skip_final_snapshot     = true
  publicly_accessible = false
  multi_az = true
}
# =========================================================================================

data "aws_route53_zone" "main" {
  name         = "nrfarms.online."
  
  
}


resource "aws_acm_certificate" "cert" {
  domain_name       = "nrfarms.online"
  validation_method = "DNS"
  subject_alternative_names = ["www.nrfarms.online"]

  lifecycle {
    create_before_destroy = true
  }
  
}

resource "aws_route53_record" "cert_validation" {
  for_each = { for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => dvo }

  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  zone_id = data.aws_route53_zone.main.zone_id
  records = [each.value.resource_record_value]
  ttl     = 60
  
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
  
}

#========================================================================================



