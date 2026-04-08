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