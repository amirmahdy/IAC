# Provider configuration
provider "aws" {
  region = var.region
}


# Create key-pair for logging into EC2
resource "aws_key_pair" "webserver-key" {
  key_name   = "webserver-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "VPC-Instance"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_subnet_cidr # Adjust subnet CIDR as needed
  availability_zone       = var.availability_zone_public # Specify desired availability zone
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet"
  }
}

# Define a route table
resource "aws_route_table" "net_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

# Associate the route table with a subnet
resource "aws_route_table_association" "my_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.net_route_table.id
}

#Create SG for allowing TCP/80 & TCP/22
resource "aws_security_group" "sg" {
  name        = "sg"
  description = "Allow TCP/80 & TCP/22"
  vpc_id      = aws_vpc.my_vpc.id
  ingress {
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "allow traffic from TCP/80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Get Linux AMI ID using SSM Parameter endpoint
data "aws_ssm_parameter" "webserver-ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# EC2 Instance
resource "aws_instance" "webserver" {
  ami           = data.aws_ssm_parameter.webserver-ami.value # Specify your desired AMI
#  ami            = "ami-0f673487d7e5f89ca" # Specify your desired AMI
  instance_type = "t2.micro"      # Specify your desired instance type
  key_name                    = aws_key_pair.webserver-key.key_name
  subnet_id             = aws_subnet.public_subnet.id
  vpc_security_group_ids        = [aws_security_group.sg.id]
  associate_public_ip_address = true # Ensure that instance gets a public IP

  tags = {
    Name = "MyEC2Instance"
  }
}


output "Webserver-Public-IP" {
  value = aws_instance.webserver.public_ip
}

