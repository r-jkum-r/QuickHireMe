
resource "aws_vpc" "my_vpc" {
  cidr_block = var.cidr_block

  tags = {
    Name = "my_vpc"
  }
}

resource "aws_subnet" "pub_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"

  tags = {
    Name = "pub_subnet"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_igw"
  }
}

resource "aws_route_table" "my_route" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "my_route"
  }
}

resource "aws_route_table_association" "asso_route" {
  subnet_id      = aws_subnet.pub_subnet.id
  route_table_id = aws_route_table.my_route.id
}

resource "aws_security_group" "my_sg" {
  name        = "my_sg"
  description = "Allow Jenkins, SonarQube, SSH, and other ports"
  vpc_id      = aws_vpc.my_vpc.id

  # Static rule for 30000–32767
  ingress {
    description      = "Custom Port Range 30000-32767"
    from_port        = 30000
    to_port          = 32767
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  # Static rule for 3000–10000
  ingress {
    description      = "Custom Port Range 3000-10000"
    from_port        = 3000
    to_port          = 10000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  # Dynamic rule for other individual ports
  dynamic "ingress" {
    for_each = [22, 25, 465, 80, 443, 8080, 9000, 9090, 6379, 6443]
    content {
      description      = "Port ${ingress.value}"
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my_sg"
  }
}
