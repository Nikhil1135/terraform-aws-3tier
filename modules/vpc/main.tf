resource "aws_vpc" "nikhil" {
  cidr_block = var.cidr_block
}

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

resource "aws_subnet" "private" {
  for_each = var.private_subnet
  vpc_id = aws_vpc.nikhil.id
  cidr_block = each.value
  availability_zone = each.key

  tags = {
    Name = "private-${each.key}"
  }
}