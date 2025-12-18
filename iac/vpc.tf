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