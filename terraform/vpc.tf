resource "aws_vpc" "my_vpc" {
  cidr_block = var.cidr_block
  tags = {
    Name = "my_vpc"
    }
}

resource "aws_subnet" "pub_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"

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
  subnet_id = aws_subnet.pub_subnet.id
  route_table_id = aws_route_table.my_route.id
}

resource "aws_security_group" "my_sg" {
  vpc_id = aws_vpc.my_vpc.id
  description = "Allowing Jenkins , Sonarqube , SSH"

  ingress = [
    for port in [22, 8080, 9000, 9090, 80] : {
      description      = "TLS from VPC"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      ipv6_cidr_blocks = ["::/0"]
      self             = false
      prefix_list_ids  = []
      security_groups  = []
      cidr_blocks      = ["0.0.0.0/0"]
    }
  ]
    egress  {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "my_sg"
        }
    }
