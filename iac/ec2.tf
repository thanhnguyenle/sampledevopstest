data "aws_ssm_parameter" "amazon_linux_2023_east" {
  provider = aws.us_east
  name     = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

data "aws_ssm_parameter" "amazon_linux_2023_singapore" {
  provider = aws.singapore
  name     = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "instance_east" {
  provider               = aws.us_east
  ami                    = data.aws_ssm_parameter.amazon_linux_2023_east.value
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.snet_east.id
  vpc_security_group_ids = [aws_security_group.asg_east.id]
  user_data              = filebase64("cloud-init.yaml")
  
  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = merge(local.common_tags, { Name = "instance-us-east-1" })
}

resource "aws_instance" "instance_singapore" {
  provider               = aws.singapore
  ami                    = data.aws_ssm_parameter.amazon_linux_2023_singapore.value
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.snet_singapore.id
  vpc_security_group_ids = [aws_security_group.asg_singapore.id]
  user_data              = filebase64("cloud-init.yaml")
  
  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = merge(local.common_tags, { Name = "instance-singapore" })
}