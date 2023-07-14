

# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "MyVPC"
  }
}


resource "aws_subnet" "my_subnet-1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet_cidr_blocks[0]  
  availability_zone = "us-east-1a"  

  tags = {
    Name = "Subnet 1"
  }
}

output "subnet-1" {
  value = aws_subnet.my_subnet-1.id
}

resource "aws_subnet" "my_subnet-2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet_cidr_blocks[1]  
  availability_zone = "us-east-1b" 

  tags = {
    Name = "Subnet 2"
  }
}

output "subnet-2" {
  value = aws_subnet.my_subnet-2.id
}

resource "aws_subnet" "my_subnet-3" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet_cidr_blocks[2]  
  availability_zone = "us-east-1c"  

  tags = {
    Name = "Subnet 3"
  }
}

output "subnet-3" {
  value = aws_subnet.my_subnet-3.id
}

resource "aws_subnet" "my_subnet-4" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet_cidr_blocks[3]  
  availability_zone = "us-east-1d"  

  tags = {
    Name = "Subnet 4"
  }
}

output "subnet-4" {
  value = aws_subnet.my_subnet-4.id
}

# Create Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "MyIGW"
  }
}
output "igw" {
  value = aws_internet_gateway.my_igw.id
  
}

# Create route table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "MyRouteTable"
  }
}

# Associate route table with subnet
resource "aws_route_table_association" "association1" {
  subnet_id      = aws_subnet.my_subnet-1.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_route_table_association" "association2" {
  subnet_id      = aws_subnet.my_subnet-2.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_route_table_association" "association3" {
  subnet_id      = aws_subnet.my_subnet-3.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_route_table_association" "association4" {
  subnet_id      = aws_subnet.my_subnet-4.id
  route_table_id = aws_route_table.my_route_table.id
}
# Create security group
resource "aws_security_group" "my_security_group" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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
    Name = "MySecurityGroup"
  }
}

output "vpc_id"{
  value = aws_vpc.my_vpc.id
}





