#Creates a VPC with a custom CIDR range (var.cidr_block), usually something like 10.0.0.0/16.

resource "aws_vpc" "my_vpc" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"

  tags = {
    Name = var.vpc_name
    Env = var.env
  }
}


#Creates an Internet Gateway (IGW) and attaches it to the VPC.Enables internet access for public subnets.

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = var.igw_name
    env = var.env
  }
  depends_on = [ aws_vpc.my_vpc ]
}



# Creates multiple public subnets using a loop (count).
resource "aws_subnet" "public_subnet" {
  count             = var.public_subnet_count
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = element(var.public_cidr_block, count.index)
  availability_zone = element(var.public_availability_zone, count.index)

  tags = {
    Name                                          = "${var.public_subnet_name}-${count.index + 1}"
    Env                                           = var.env
    # "kubernetes.io/cluster/${local.cluster-name}" = "owned"
    "kubernetes.io/role/elb"                      = "1"
  }
  depends_on = [aws_vpc.my_vpc]
}


#Creates multiple private subnets using a loop (count).
resource "aws_subnet" "private_subnet" {
  count                   = var.private_subnet_count
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = element(var.private_cidr_block, count.index)
  availability_zone       = element(var.private_availability_zone, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name                                          = "${var.private_subnet_name}-${count.index + 1}"
    Env                                           = var.env
    # "kubernetes.io/cluster/${local.cluster-name}" = "owned"
    "kubernetes.io/role/internal-elb"             = "1"
  }

  depends_on = [aws_vpc.my_vpc]
}


# Creates a route table for public subnets and associates it with each public subnet.
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.public_route_table_name
    env  = var.env
  }

  depends_on = [aws_vpc.my_vpc]
}



# Associating Public Subnet  route table
resource "aws_route_table_association" "public_subnet_route_table_association" {
  count          = 3
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.public_subnet[count.index].id

  depends_on = [aws_vpc.my_vpc,
    aws_subnet.public_subnet ]
}

#Creates a NAT Gateway with a static Elastic IP in one of the public subnets.
resource "aws_eip" "nat_gateway_eip" {
  domain = "vpc"

  tags = {
    Name = var.eip_name
  }

  depends_on = [aws_vpc.my_vpc]

}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = var.nat_gateway_name
  }

  depends_on = [aws_vpc.my_vpc,aws_eip.nat_gateway_eip]
}

# Private Route Table and Association, Ensures that private subnet traffic outbound to the internet flows via NAT.
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = var.private_route_table_name
    env  = var.env
  }
}

resource "aws_route_table_association" "private-rt-association" {
  count          = 3
  route_table_id = aws_route_table.private_rt.id
  subnet_id      = aws_subnet.private_subnet[count.index].id

  depends_on = [aws_vpc.my_vpc,
    aws_subnet.private_subnet]
}

resource "aws_security_group" "eks-cluster-sg" {
  name        = var.eks_sg
  description = "Allow 443 from Jump Server only"

  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // It should be specific IP range
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.eks_sg
  }
}



