# Resource-1: create VPC and call it fully-automated-cicd-VPC
resource "aws_vpc" "fully-automated-cicd-VPC" {
  cidr_block       = var.vpc_cidir
  enable_dns_hostnames = true
  tags = {
    Name = "fully-automated-cicd-VPC"
  }
}

# Resource-2: create Subnet
resource "aws_subnet" "fully-automated-cicd-VPC-Pub-sbn" {
  vpc_id     = aws_vpc.fully-automated-cicd-VPC.id
  cidr_block = var.subnet_cidir
  availability_zone = "us-east-2b"
  map_public_ip_on_launch = true
    tags = {
    Name = "fully-automated-cicd-VPC-Pub-sbn"
  }
}

# Resource-3: create internet gatewaay
resource "aws_internet_gateway" "fully-automated-cicd-VPC-igw" {
  vpc_id = aws_vpc.fully-automated-cicd-VPC.id
  
  tags = {
    Name = "fully-automated-cicd-VPC-igw"
  }
}

# Resource-4: create public route table
resource "aws_route_table" "fully-automated-cicd-VPC-Pub-RT" {
  vpc_id = aws_vpc.fully-automated-cicd-VPC.id
}

# Resource-5: create route
resource "aws_route" "fully-automated-cicd-VPC-Pub-Route" {
  route_table_id            = aws_route_table.fully-automated-cicd-VPC-Pub-RT.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.fully-automated-cicd-VPC-igw.id
  depends_on                = [aws_route_table.fully-automated-cicd-VPC-Pub-RT]
  count                     = "1"
}

# Resource-6: Associate Public Route Table with Public subnet
resource "aws_route_table_association" "fully-automated-cicd-VPC-Pub-RT-Asso" {
  subnet_id      = aws_subnet.fully-automated-cicd-VPC-Pub-sbn.id
  route_table_id = aws_route_table.fully-automated-cicd-VPC-Pub-RT.id
}

#  To replace all same phrase at once with a new phrase ~~~>>> Ctrl + Shift + L  and paste the new phrase.