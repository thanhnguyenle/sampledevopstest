resource "aws_internet_gateway" "igw_east" {
  provider = aws.us_east
  vpc_id   = aws_vpc.vpc_east.id
  tags     = merge(local.common_tags, { Name = "igw-us-east-1" })
}

resource "aws_internet_gateway" "igw_singapore" {
  provider = aws.singapore
  vpc_id   = aws_vpc.vpc_singapore.id
  tags     = merge(local.common_tags, { Name = "igw-singapore" })
}