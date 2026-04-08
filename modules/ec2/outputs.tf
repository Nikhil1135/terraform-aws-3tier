# output "public_ip_of_ec2" {
# value = aws_instance.nikhil.public_ip
  
# }

# output "instance_id" {
#   value = aws_instance.nikhil.id
# }

output "e2_sg_id" {
  value = aws_security_group.ec2_sg.id
}