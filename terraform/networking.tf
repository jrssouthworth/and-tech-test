#Create VPC
resource "aws_vpc" "and_vpc" {
  cidr_block           = var.and_vpc
}

#Create 3 Public Subnets, 1 per AZ
resource "aws_subnet" "public_subnet" {
  count             = var.and_vpc == "10.0.0.0/16" ? 3 : 0
  vpc_id            = aws_vpc.and_vpc.id
  availability_zone = data.aws_availability_zones.azs.names[count.index]
  cidr_block        = cidrsubnet(var.and_vpc, 8, 0 + count.index)

  tags = {
    "Name" = "Public-Subnet-${count.index}"
  }
}

#Create 3 Private Subnets, 1 per AZ
resource "aws_subnet" "private_subnet" {
  count             = var.and_vpc == "10.0.0.0/16" ? 3 : 0
  vpc_id            = aws_vpc.and_vpc.id
  availability_zone = data.aws_availability_zones.azs.names[count.index]
  cidr_block        = cidrsubnet(var.and_vpc, 8, 4 + count.index)
  map_public_ip_on_launch = false

  tags = {
    "Name" = "Private-Subnet-${count.index}"
  }
}

#Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.and_vpc.id

  tags = {
    "Name" = "Internet-Gateway"
  }
}

#Create Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.and_vpc.id

  tags = {
    "Name" = "Public-RT"
  }
}

#Create Public Route
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

#Create Public Route Table Asssociations 
resource "aws_route_table_association" "public_rt_association" {
  count          = length(aws_subnet.public_subnet) == 3 ? 3 : 0
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
}

#Get Elastic IP for NAT
resource "aws_eip" "eip_nat" {
  count            = length(aws_subnet.public_subnet) == 3 ? 3 : 0
  vpc              = true

  tags = {
    "Name" = "EIP-NAT-${count.index}"
  }
}

#Create NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  count         = length(aws_eip.eip_nat)
  subnet_id     = element(aws_subnet.public_subnet.*.id, count.index)
  allocation_id = element(aws_eip.eip_nat.*.id, count.index)

  tags = {
    Name = "nat-gateway-${count.index}"
  }
}

#Create Route Table targetting NAT Gateway
resource "aws_route_table" "NAT_route_table" {
  vpc_id = aws_vpc.and_vpc.id
  count            = length(aws_nat_gateway.nat_gateway) == 3 ? 3 : 0

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = element(aws_nat_gateway.nat_gateway.*.id, count.index)
  }

  tags = {
    Name = "NAT-route-table${count.index}"
  }
}

#Create Private Route Table Association
resource "aws_route_table_association" "private_rt_association" {
count            = 3


  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.NAT_route_table.*.id, count.index)
}
