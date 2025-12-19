resource "aws_vpc" "vpc_east" {
  provider             = aws.us_east
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = merge(local.common_tags, { Name = "vpc-us-east-1" })
}

resource "aws_vpc" "vpc_east2" {
  provider             = aws.us_east_2
  cidr_block           = "10.2.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = merge(local.common_tags, { Name = "vpc-east2" })
}

resource "aws_vpc_peering_connection" "peer" {
  provider    = aws.us_east
  vpc_id      = aws_vpc.vpc_east.id
  peer_vpc_id = aws_vpc.vpc_east2.id
  peer_region = "us-east-2"
  
  tags = merge(local.common_tags, { Name = "vpc-east-to-east2" })
}

resource "aws_vpc_peering_connection_accepter" "peer_accepter" {
  provider                  = aws.us_east_2
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  auto_accept               = true
  
  tags = merge(local.common_tags, { Name = "vpc-east2-accepter" })
}