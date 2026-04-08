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

#===========================================================

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.nikhil.id

  tags = {
    Name = "main-igw"
  }
  
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.nikhil.id

  tags = {
    Name = "public-rt"
  }
  
}

resource "aws_route" "internet" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
  
}

resource "aws_route_table_association" "public" {
for_each = aws_subnet.public

subnet_id = each.value.id
route_table_id = aws_route_table.public.id

}
#====================================================================
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "nat-eip"
  }
  
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id = values(aws_subnet.public)[0].id

  tags = {
    Name = "main-nat"
  }
  
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.nikhil.id

  tags = {
    Name = "private-rt"
  }
}

resource "aws_route" "private_internet" {
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id = each.value.id
  route_table_id =aws_route_table.private.id
  
}