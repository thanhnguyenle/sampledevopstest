resource "aws_subnet" "snet_east" {
  provider                = aws.us_east
  vpc_id                  = aws_vpc.vpc_east.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags                    = merge(local.common_tags, { Name = "subnet-us-east-1" })
}

resource "aws_subnet" "snet_singapore" {
  provider                = aws.singapore
  vpc_id                  = aws_vpc.vpc_singapore.id
  cidr_block              = "10.2.1.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true
  tags                    = merge(local.common_tags, { Name = "subnet-singapore" })
}