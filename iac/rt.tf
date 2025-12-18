resource "aws_route_table" "rt_east" {
  provider = aws.us_east
  vpc_id   = aws_vpc.vpc_east.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_east.id
  }

  tags = merge(local.common_tags, { Name = "rt-us-east-1" })
}

resource "aws_route_table_association" "rta_east" {
  provider       = aws.us_east
  subnet_id      = aws_subnet.snet_east.id
  route_table_id = aws_route_table.rt_east.id
}

resource "aws_route_table" "rt_singapore" {
  provider = aws.singapore
  vpc_id   = aws_vpc.vpc_singapore.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_singapore.id
  }

  tags = merge(local.common_tags, { Name = "rt-singapore" })
}

resource "aws_route_table_association" "rta_singapore" {
  provider       = aws.singapore
  subnet_id      = aws_subnet.snet_singapore.id
  route_table_id = aws_route_table.rt_singapore.id
}