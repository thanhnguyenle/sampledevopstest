resource "aws_vpc" "vpc_east" {
  provider             = aws.us_east
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = merge(local.common_tags, { Name = "vpc-us-east-1" })
}

resource "aws_vpc" "vpc_singapore" {
  provider             = aws.singapore
  cidr_block           = "10.2.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = merge(local.common_tags, { Name = "vpc-singapore" })
}

resource "aws_vpc_peering_connection" "peer" {
  provider    = aws.us_east
  vpc_id      = aws_vpc.vpc_east.id
  peer_vpc_id = aws_vpc.vpc_singapore.id
  peer_region = "ap-southeast-1"
  
  tags = merge(local.common_tags, { Name = "vpc-east-to-singapore" })
}

resource "aws_vpc_peering_connection_accepter" "peer_accepter" {
  provider                  = aws.singapore
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  auto_accept               = true
  
  tags = merge(local.common_tags, { Name = "vpc-singapore-accepter" })
}