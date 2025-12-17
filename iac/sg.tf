resource "aws_security_group" "asg_instance_01" {
  name_prefix = "instance-01-allow-http-ssh"
  description = "Instance 01 SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP access (API)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH access (Ansible)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow HTTPS outbound (packages)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow HTTP outbound (packages)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_security_group" "asg_instance_02" {
  name_prefix = "instance-02-allow-internal-from-instance-01"
  description = "Instance 02 SG"
  vpc_id      = aws_vpc.main.id

  tags = local.common_tags
}

resource "aws_security_group_rule" "icmp_egress_01_to_02" {
  type                     = "egress"
  from_port                = -1
  to_port                  = -1
  protocol                 = "icmp"
  security_group_id         = aws_security_group.asg_instance_01.id
  source_security_group_id  = aws_security_group.asg_instance_02.id
  description              = "ICMP from Instance 01 to Instance 02"
}

resource "aws_security_group_rule" "icmp_ingress_02_from_01" {
  type                     = "ingress"
  from_port                = -1
  to_port                  = -1
  protocol                 = "icmp"
  security_group_id         = aws_security_group.asg_instance_02.id
  source_security_group_id  = aws_security_group.asg_instance_01.id
  description              = "Allow ICMP from Instance 01"
}

resource "aws_security_group_rule" "udp_traceroute_egress_01_to_02" {
  type                     = "egress"
  from_port                = 33434
  to_port                  = 33534
  protocol                 = "udp"
  security_group_id         = aws_security_group.asg_instance_01.id
  source_security_group_id  = aws_security_group.asg_instance_02.id
  description              = "Traceroute UDP from Instance 01 to Instance 02"
}

resource "aws_security_group_rule" "udp_traceroute_ingress_02_from_01" {
  type                     = "ingress"
  from_port                = 33434
  to_port                  = 33534
  protocol                 = "udp"
  security_group_id         = aws_security_group.asg_instance_02.id
  source_security_group_id  = aws_security_group.asg_instance_01.id
  description              = "Allow traceroute UDP from Instance 01"
}
