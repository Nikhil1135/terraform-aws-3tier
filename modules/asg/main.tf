resource "aws_launch_template" "lt" {
  name_prefix   = "app-lt"
  image_id      = var.ami
  instance_type = "t2.micro"

  vpc_security_group_ids = var.e2_sg_id
   # vpc_security_group_ids = [module.ec2.e2_sg_id]

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

  vpc_zone_identifier = var.private_subnet_ids
   # vpc_zone_identifier = module.network.private_subnet_ids

  target_group_arns = var.target_group_arn  # ASG automatically registers instances with target group

  # target_group_arns = [aws_lb_target_group.tg.arn]

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