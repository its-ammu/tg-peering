
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
  route_table_id            = aws_route_table.pubrt.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
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
  peer_account_id         = aws_ec2_transit_gateway.tg02.owner_id
  peer_region             = "us-west1"
  peer_transit_gateway_id = aws_ec2_transit_gateway.tg02.id
  transit_gateway_id      = aws_ec2_transit_gateway.tg01.id

  tags = {
    Name = "TGW Peering Requestor"
  }
}

