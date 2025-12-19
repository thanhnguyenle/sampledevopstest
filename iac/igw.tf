resource "aws_internet_gateway" "igw_east" {
  provider = aws.us_east
  vpc_id   = aws_vpc.vpc_east.id
  tags     = merge(local.common_tags, { Name = "igw-us-east-1" })
}

resource "aws_internet_gateway" "igw_east2" {
  provider = aws.us_east_2
  vpc_id   = aws_vpc.vpc_east2.id
  tags     = merge(local.common_tags, { Name = "igw-east2" })
}