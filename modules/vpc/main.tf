resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name ="main"
  }
}

resource "aws_subnet" "public" {
  # vpc_id = aws_vpc.main.id
  # cidr_block = var.public_cidr
  # map_public_ip_on_launch = true
  # availability_zone ="us-east-1a"
  # tags = {
  #   Name ="Public-subnet"
  # }
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.public_availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "Private-subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Public-route-table"
  }
  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Private-route-table"
  }
  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }
}

resource "aws_route_table_association" "ass_public" {
  route_table_id = aws_route_table.public_rt.id 
  count          = length(aws_subnet.private)  
  subnet_id = aws_subnet.public[count.index].id
}

resource "aws_route_table_association" "ass_private" {
  route_table_id = aws_route_table.private_rt.id
  count          = length(aws_subnet.private)  
  subnet_id = aws_subnet.private[count.index].id
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id
    tags = {
      Name = "IGW"
    }
  
}

resource "aws_security_group" "public_Sg" {
  name = "publci-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow ssh from anywhere"
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from anywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Public-SG"
  }
}

resource "aws_security_group" "private_Sg" {
  name = "private-sg"
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Private-SG"
  }
}

resource "aws_eip" "eip" {
  domain = "vpc"
  tags = {
    Name ="nat-eip"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip.id
  subnet_id = aws_subnet.public[0].id
}