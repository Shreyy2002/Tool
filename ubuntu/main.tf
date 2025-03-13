provider "aws" {
  region     = "ap-south-1"
  }

resource "aws_vpc" "tool_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support     = true
  enable_dns_hostnames   = true

tags = {
    Name = "tool-vpc"
  }
}

resource "aws_subnet" "tool_subnet" {
  vpc_id                  = aws_vpc.tool_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

tags = {
    Name = "tool-subnet"
  }
}

resource "aws_security_group" "tool_security_group" {
  name        = "tool-security-group"
  description = "Allow SSH access"
  vpc_id      = aws_vpc.tool_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["122.171.23.186/32"]
  }
  
  


  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.tool_vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "tool_tomcat" {
  ami             = "ami-03f4878755434977f"
  instance_type   = "t2.micro"
  key_name        = "tool"
  subnet_id       = aws_subnet.tool_subnet.id
  vpc_security_group_ids  = [aws_security_group.tool_security_group.id]
  associate_public_ip_address = true

  tags = {
    Name = "tomcat-server"
  }
}

resource "aws_instance" "tool_monitor" {
  ami             = "ami-03f4878755434977f"
  instance_type   = "t2.micro"
  key_name        = "tool"
  subnet_id       = aws_subnet.tool_subnet.id
  vpc_security_group_ids  = [aws_security_group.tool_security_group.id]
  associate_public_ip_address = true

  tags = {
    Name = "monitor-server"
  }
}


resource "aws_internet_gateway" "tool_igw" {
  vpc_id = aws_vpc.tool_vpc.id

tags = {
    Name = "tool-igw"
  }
}

resource "aws_route_table" "tool_route_table" {
  vpc_id = aws_vpc.tool_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tool_igw.id
  }
}

resource "aws_route_table_association" "tool_subnet_association" {
  subnet_id      = aws_subnet.tool_subnet.id
  route_table_id = aws_route_table.tool_route_table.id
}

output "instance_public_ip_tomcat" {
  value = aws_instance.tool_tomcat.public_ip
}

output "instance_public_ip_monitor" {
  value = aws_instance.tool_monitor.public_ip
}
