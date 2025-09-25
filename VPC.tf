
resource "aws_vpc" "myVPC" {
  cidr_block = var.cidr

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "myIGW" {
  vpc_id = aws_vpc.myVPC.id
  tags = {
    Name = var.internet_gateway
  }
}

resource "aws_subnet" "PulicSubnet" {
    vpc_id = aws_vpc.myVPC.id
    cidr_block = "192.168.1.0/24"
    availability_zone = data.aws_availability_zones.myAZ.names[0]
    map_public_ip_on_launch = var.map_public_ip_on_launch
    tags = {
        Name = "public_subnet"
    }
}

resource "aws_subnet" "PrivateSubnet" {
    vpc_id = aws_vpc.myVPC.id
    cidr_block = "192.168.2.0/24"
    availability_zone = data.aws_availability_zones.myAZ.names[1]
    map_public_ip_on_launch = var.map_public_ip_on_launch
    tags = {
        Name = "private_subnet"
    }
}

resource "aws_route_table" "PublicRouteTable" {
  vpc_id = aws_vpc.myVPC.id
  tags = {
    Name = var.Public_route_table
  }
}

resource "aws_route" "publicRoute" {
  route_table_id = aws_route_table.PublicRouteTable.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.myIGW.id
}

resource "aws_route_table" "PrivateRouteTable" {
  vpc_id = aws_vpc.myVPC.id
  tags = {
    Name = var.Private_route_table
  }
}

resource "aws_route_table_association" "publicRouteAssoc" {
  subnet_id = aws_subnet.PulicSubnet.id
  route_table_id = aws_route_table.PublicRouteTable.id
}

resource "aws_route_table_association" "privateRouteAssoc" {
  subnet_id = aws_subnet.PrivateSubnet.id
  route_table_id = aws_route_table.PrivateRouteTable.id
}

resource "aws_instance" "myEC2" {
  subnet_id     = aws_subnet.PrivateSubnet.id
  ami           = "ami-08982f1c5bf93d976"
  instance_type = "t2.micro"
  key_name      = var.key_name

  tags = {
    Name = var.myEC2
  }
}
