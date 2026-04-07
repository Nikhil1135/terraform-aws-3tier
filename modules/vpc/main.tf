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

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.nikhil.id

  tags = {
    Name = "main-igw"
  }
  
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.nikhil.id
  
}

resource "aws_route" "internet" {
  route_table_id = aws_route_table.public
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
  
}

resource "aws_route_table_association" "public" {
for_each = aws_subnet.public

subnet_id = each.value.id
route_table_id = aws_route_table.public.id

}