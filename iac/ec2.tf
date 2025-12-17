data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "instance_01" {
  ami                    = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.snet_instance_01.id
  vpc_security_group_ids = [aws_security_group.asg_instance_01.id]
  user_data              = filebase64("cloud-init.yaml")
  
  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = merge(local.common_tags, { Name = "instance-01" })

  depends_on = [
    aws_security_group.asg_instance_01,
    aws_subnet.snet_instance_01,
    data.aws_ssm_parameter.amazon_linux_2023
  ]
}

resource "aws_instance" "instance_02" {
  ami                    = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.snet_instance_02.id
  vpc_security_group_ids = [aws_security_group.asg_instance_02.id]
  user_data              = filebase64("cloud-init.yaml")
  
  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = merge(local.common_tags, { Name = "instance-02" })

  depends_on = [
    aws_security_group.asg_instance_02,
    aws_subnet.snet_instance_02,
    data.aws_ssm_parameter.amazon_linux_2023
  ]
}

