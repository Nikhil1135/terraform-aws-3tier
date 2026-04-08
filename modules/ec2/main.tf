resource "aws_instance" "nikhil" {
  ami = var.ami
  instance_type = var.instance_type
  subnet_id = var.subnet_id
  key_name = var.key_name
  # associate_public_ip_address = true

    user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              systemctl start nginx
              systemctl enable nginx
              echo "Nikhil's new Terraform Project" > /usr/share/nginx/html/index.html
              EOF

  tags = {
    Name = "terraform-ec2"
  }
  vpc_security_group_ids = [ aws_security_group.ec2_sg.id ]
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # for testing only
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [ var.alb_sg_id ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



