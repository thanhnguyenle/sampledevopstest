resource "aws_route_table" "route_traffic_to_igw" {
  vpc_id       = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags         = local.common_tags
}

resource "aws_route_table_association" "rta_instance01" {
  subnet_id      = aws_subnet.snet_instance_01.id
  route_table_id = aws_route_table.route_traffic_to_igw.id
}
