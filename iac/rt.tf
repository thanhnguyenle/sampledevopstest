resource "aws_route_table" "rt_east" {
  provider = aws.us_east
  vpc_id   = aws_vpc.vpc_east.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_east.id
  }

  route {
    cidr_block                = aws_vpc.vpc_east2.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  }

  tags = merge(local.common_tags, { Name = "rt-us-east-1" })
}

resource "aws_route_table" "rt_east2" {
  provider = aws.us_east_2
  vpc_id   = aws_vpc.vpc_east2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_east2.id
  }

  route {
    cidr_block                = aws_vpc.vpc_east.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  }

  tags = merge(local.common_tags, { Name = "rt-east2" })
}

resource "aws_route_table_association" "rta_east" {
  provider       = aws.us_east
  subnet_id      = aws_subnet.snet_east.id
  route_table_id = aws_route_table.rt_east.id
}

resource "aws_route_table_association" "rta_east2" {
  provider       = aws.us_east_2
  subnet_id      = aws_subnet.snet_east2.id
  route_table_id = aws_route_table.rt_east2.id
}