output "aws_vpc_id" {
  description = "The value of the VPC ID"
  value = aws_vpc.nikhil.id
}

output "public_subnet_ids" {
  value = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  value = [for subnet in aws_subnet.private : subnet.id]
}
