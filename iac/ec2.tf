data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "instance_01" {
  ami                    = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type          = "m5.large"
  subnet_id              = aws_subnet.snet_instances.id
  vpc_security_group_ids = [aws_security_group.asg_instances.id]
  placement_group        = aws_placement_group.cluster.id
  user_data              = filebase64("cloud-init.yaml")
  
  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = merge(local.common_tags, { Name = "instance-01" })

  depends_on = [
    aws_security_group.asg_instances,
    aws_subnet.snet_instances,
    data.aws_ssm_parameter.amazon_linux_2023
  ]
}

resource "aws_instance" "instance_02" {
  ami                    = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type          = "m5.large"
  subnet_id              = aws_subnet.snet_instances.id
  vpc_security_group_ids = [aws_security_group.asg_instances.id]
  placement_group        = aws_placement_group.cluster.id
  user_data              = filebase64("cloud-init.yaml")
  
  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = merge(local.common_tags, { Name = "instance-02" })

  depends_on = [
    aws_security_group.asg_instances,
    aws_subnet.snet_instances,
    data.aws_ssm_parameter.amazon_linux_2023
  ]
}

