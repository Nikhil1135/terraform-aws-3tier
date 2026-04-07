# terraform-aws-3tier

# Challenges faced during this project.
=======================================================================================
> While creating multiple subnets I have used foreach loop instead of count. Like map(string)

resource "aws_subnet" "public" {
  for_each = var.public_subnet
  vpc_id = aws_vpc.nikhil.id
  cidr_block = each.value
  availability_zone = each.key

  map_public_ip_on_launch = true

  tags = {
    Name = "public-${each.key}"
  }
}

output "public_subnet_ids" {
  value = [for subnet in aws_subnet.public : subnet.id]
}
>> It loops through all subnets and collects subnet.id
=========================================================================================
# Whatever the variables you declare in module var.tf those need to be declared in root var.tf and parsed via the root main.tf

=========================================================================================
# Variables are evaluated BEFORE modules/resources
> Suppose you have declared a variable called a, it has to be given a value. If you reference it with a runtime value it throws an error.
Variables = static input only
Module outputs = dynamic values

> you can see I have commented out subnet_id in root variables.tf and referenced it in root module main.tf as
subnet_id = module.network.public_subnet_ids[0]
=========================================================================================
# Also you need to initialize your project if you create a module.
=========================================
# When attaching SG to instance you need to use sg.id 