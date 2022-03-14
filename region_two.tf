
# AWS VPC - Region 2

resource "aws_vpc" "vpc02" {
  provider         = aws.region2
  cidr_block       = "27.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "VPC 02"
  }
}

# Private subnet - Region 2

resource "aws_subnet" "privatesub02" {
  provider   = aws.region2
  vpc_id     = aws_vpc.vpc02.id
  cidr_block = "27.0.2.0/24"

  tags = {
    Name = "PrivSub02"
  }
}

# Private route table - Region 2

resource "aws_route_table" "privrt02" {
  provider = aws.region2
  vpc_id   = aws_vpc.vpc02.id

  tags = {
    Name = "PrivRT"
  }
}

resource "aws_route_table_association" "privsub_ass02" {
  provider       = aws.region2
  subnet_id      = aws_subnet.privatesub02.id
  route_table_id = aws_route_table.privrt02.id
}

# TG Region 2

resource "aws_ec2_transit_gateway" "tg02" {
  provider    = aws.region2
  description = "TG in region 2"
}


# TG peering acceptor

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "example" {
  provider                      = aws.region2
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.tg_peer.id

  tags = {
    Name = "Inter region peering"
  }
}

# TG VPC attachment

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_attach02" {
  provider           = aws.region2
  subnet_ids         = [aws_subnet.privatesub02.id]
  transit_gateway_id = aws_ec2_transit_gateway.tg02.id
  vpc_id             = aws_vpc.vpc02.id
}

# TG Peering route

resource "aws_ec2_transit_gateway_route" "peer_route2" {
  provider                       = aws.region2
  destination_cidr_block         = "27.0.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tg_peer.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.tg02.association_default_route_table_id
}

# Subnet route

resource "aws_route" "tg_route02" {
  route_table_id         = aws_route_table.privrt02
  destination_cidr_block = "27.0.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.tg02.id
}

# Ec2 security group

resource "aws_security_group" "sg02" {
  name        = "PING and SSH"
  description = "Security group for web server with ssh allowed"
  vpc_id      = data.aws_vpc.vpc02.id
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

resource "aws_instance" "private02" {
  ami             = "ami-0a8a24772b8f01294"
  subnet_id       = aws_subnet.privatesub02
  security_groups = [aws_security_group.sg02]
  instance_type   = "t2.micro"
  key_name        = "practicewest"
}

