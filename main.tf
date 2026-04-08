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
  alb_sg_id = aws_security_group.alb_sg.id
}

#==========================================================
resource "aws_security_group" "alb_sg" {
  name   = "alb-sg"
  vpc_id = module.network.aws_vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "app_alb" {
  name               = "app-alb"
  load_balancer_type = "application"
  subnets            = module.network.public_subnet_ids
  security_groups    = [aws_security_group.alb_sg.id]

  tags = {
    Name = "app-alb"
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.network.aws_vpc_id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

# resource "aws_lb_target_group_attachment" "tg_attach" {
#   target_group_arn = aws_lb_target_group.tg.arn
#   target_id        = module.ec2.instance_id               # Manual attachment of ec2 instance
#   port             = 80
# }

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

#================================================== ASG below=======================================
resource "aws_launch_template" "lt" {
  name_prefix   = "app-lt"
  image_id      = var.ami
  instance_type = "t2.micro"

  vpc_security_group_ids = [module.ec2.e2_sg_id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              systemctl start nginx
              systemctl enable nginx
              echo "Hostname: $(hostname)" >> /usr/share/nginx/html/index.html

              EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "asg-instance"
    }
  }
}

resource "aws_autoscaling_group" "asg" {
  desired_capacity = 2
  max_size         = 3
  min_size         = 1

  vpc_zone_identifier = module.network.private_subnet_ids

  target_group_arns = [aws_lb_target_group.tg.arn]  # ASG automatically registers instances with target group

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = "asg-ec2"
    propagate_at_launch = true
  }
}