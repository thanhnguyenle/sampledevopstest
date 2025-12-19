resource "aws_subnet" "snet_east" {
  provider                = aws.us_east
  vpc_id                  = aws_vpc.vpc_east.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags                    = merge(local.common_tags, { Name = "subnet-us-east-1" })
}

resource "aws_subnet" "snet_east2" {
  provider                = aws.us_east_2
  vpc_id                  = aws_vpc.vpc_east2.id
  cidr_block              = "10.2.1.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true
  tags                    = merge(local.common_tags, { Name = "subnet-east2" })
}