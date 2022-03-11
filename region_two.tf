
# AWS VPC - Region 2

resource "aws_vpc" "vpc02" {
  provider = aws.region2
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "VPC 02"
  }
}

# Private subnet - Region 2

resource "aws_subnet" "privsub02" {
  provider = aws.region2
  vpc_id     = aws_vpc.vpc02.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "PrivSub02"
  }
}

resource "aws_route_table" "privrt02" {
  provider = aws.region2
  vpc_id = aws_vpc.vpc02.id

  tags = {
    Name = "PrivRT"
  }
}

resource "aws_route_table_association" "Privsubassoc02" {
  provider = aws.region2
  subnet_id      = aws_subnet.privsub02.id
  route_table_id = aws_route_table.privrt02.id
}

# TG Region 2

resource "aws_ec2_transit_gateway" "tg02" {
  provider = aws.region2
  description = "tg in region 2"
}

# TG peering acceptor