
# AWS VPC - Region 1

resource "aws_vpc" "vpc01" {
  cidr_block       = "27.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "VPC 01"
  }
}



# Public subnet Region 1

resource "aws_subnet" "publicsub" {
  vpc_id     = aws_vpc.vpc01.id
  cidr_block = "27.0.1.0/24"

  tags = {
    Name = "PubSub01"
  }
}

# IG Region 1

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc01.id

  tags = {
    Name = "IG-01"
  }
}

# Public RT table Region 1

resource "aws_route_table" "pubrt" {
  vpc_id = aws_vpc.vpc01.id

  tags = {
    Name = "PubRT"
  }
}

resource "aws_route" "ig_rt" {
  route_table_id         = aws_route_table.pubrt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "pubsub_ass" {
  subnet_id      = aws_subnet.publicsub.id
  route_table_id = aws_route_table.pubrt.id
}

# Private subnet - Region 1

resource "aws_subnet" "privatesub01" {
  vpc_id     = aws_vpc.vpc01.id
  cidr_block = "27.0.2.0/24"

  tags = {
    Name = "PrivSub01"
  }
}

# Private route table - Region 1

resource "aws_route_table" "privrt01" {
  vpc_id = aws_vpc.vpc01.id

  tags = {
    Name = "PrivRT"
  }
}

resource "aws_route_table_association" "privsub_ass01" {
  subnet_id      = aws_subnet.privsub01.id
  route_table_id = aws_route_table.privrt01.id
}

# TG Region 1

resource "aws_ec2_transit_gateway" "tg01" {
  description = "TGW in region 1"
}


# TG Peering requestor

resource "aws_ec2_transit_gateway_peering_attachment" "tg_peer" {

  peer_region             = "us-west1"
  peer_transit_gateway_id = aws_ec2_transit_gateway.tg02.id
  transit_gateway_id      = aws_ec2_transit_gateway.tg01.id

  tags = {
    Name = "TGW Peering Requestor"
  }
}

# TG VPC attachment

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_attach01" {
  subnet_ids         = [aws_subnet.privatesub01.id]
  transit_gateway_id = aws_ec2_transit_gateway.tg01.id
  vpc_id             = aws_vpc.vpc01.id
}

# TG Peering route

resource "aws_ec2_transit_gateway_route" "peer_route1" {
  destination_cidr_block         = "28.0.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tg_peer.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.tg01.association_default_route_table_id
}

# Subnet route

resource "aws_route" "tg_route01" {
  route_table_id         = aws_route_table.privrt01
  destination_cidr_block = "28.0.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.tg01.id
}

# Ec2 security group

resource "aws_security_group" "sg01" {
  name        = "PING and SSH"
  description = "Security group for web server with ssh allowed"
  vpc_id      = data.aws_vpc.vpc01.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# Private EC2

resource "aws_instance" "private01" {
  ami             = "ami-0c293f3f676ec4f90"
  subnet_id       = aws_subnet.privatesub01
  security_groups = [aws_security_group.sg01]
  instance_type   = "t2.micro"
  key_name        = "practice"
}

# Public EC2

resource "aws_instance" "public01" {
  ami             = "ami-0c293f3f676ec4f90"
  subnet_id       = aws_subnet.publicsub
  security_groups = [aws_security_group.sg01]
  instance_type   = "t2.micro"
  key_name        = "practice"
}
