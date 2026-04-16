output "aws_vpc_id" {
  value = module.network.aws_vpc_id
}



output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

# output "public_ip_of_ec2" {
#   value = module.ec2.public_ip_of_ec2
# }

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "target_group_arn" {
  value = module.alb.target_group_arn
}

output "e2_sg_id" {
  value = module.ec2.e2_sg_id
}

output "db_endpoint" {
  value = aws_db_instance.db.endpoint
} 