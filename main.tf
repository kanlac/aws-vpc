data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ubuntu_ami_pattern]
  }

  owners = ["099720109477"] # Canonical Ubuntu AMI owner
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_prefix}-vpc"
  }
}

data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}

# Public subnets - one per AZ
resource "aws_subnet" "public_subnets" {
  count = var.enable_availability_zone_num

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.${count.index + var.public_subnet_offset}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true # Auto-assign public IPs to instances launched in these subnets

  tags = {
    Name = "${var.project_prefix}-public-subnet-${count.index + 1}"
  }
}

# Internet Gateway for public subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_prefix}-igw"
  }
}

# Route table for public subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_prefix}-public-rt"
  }
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public_rta" {
  count = var.enable_availability_zone_num

  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# Security group for public instances
resource "aws_security_group" "public_sg" {
  name        = "${var.project_prefix}-public-sg"
  description = "Security group for public instances"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow SSH from anywhere"
    from_port   = var.allowed_ports.ssh
    to_port     = var.allowed_ports.ssh
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = var.allowed_ports.http
    to_port     = var.allowed_ports.http
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_prefix}-public-sg"
  }
}

# EC2 instances in public subnets
resource "aws_instance" "public_instances" {
  count = var.enable_availability_zone_num

  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  subnet_id                   = aws_subnet.public_subnets[count.index].id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.public_sg.id]

  tags = {
    Name = "${var.project_prefix}-public-instance-${count.index + 1}"
  }
}

# Private subnets - one per AZ
resource "aws_subnet" "private_subnets" {
  count = var.enable_availability_zone_num

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.${count.index + var.private_subnet_offset}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.project_prefix}-private-subnet-${count.index + 1}"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "${var.project_prefix}-nat-eip"
  }
}

# NAT Gateway for private subnets
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets[0].id # Placed in the first public subnet

  tags = {
    Name = "${var.project_prefix}-nat-gateway"
  }

  depends_on = [aws_internet_gateway.igw] # Ensure IGW is created first
}

# Route table for private subnets
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "${var.project_prefix}-private-rt"
  }
}

# Associate private subnets with private route table
resource "aws_route_table_association" "private_rta" {
  count = var.enable_availability_zone_num

  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

# EC2 instances in private subnets
resource "aws_instance" "private_instances" {
  count = var.enable_availability_zone_num

  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  subnet_id                   = aws_subnet.private_subnets[count.index].id
  associate_public_ip_address = false # No public IPs for private instances
  vpc_security_group_ids      = [aws_security_group.private_sg.id]

  tags = {
    Name = "${var.project_prefix}-private-instance-${count.index + 1}"
  }
}

# Security group for private instances
resource "aws_security_group" "private_sg" {
  name        = "${var.project_prefix}-private-sg"
  description = "Security group for private instances"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow SSH from within VPC"
    from_port   = var.allowed_ports.ssh
    to_port     = var.allowed_ports.ssh
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  egress {
    description = "Allow all outbound traffic through NAT Gateway"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_prefix}-private-sg"
  }
}