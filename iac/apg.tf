resource "aws_placement_group" "cluster" {
  name     = "same-rack-cluster"
  strategy = "cluster"
  tags     = local.common_tags
}