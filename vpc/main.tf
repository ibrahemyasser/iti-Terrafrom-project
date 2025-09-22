resource "aws_vpc" "mainVpc" {
  cidr_block           = var.vpc_cidr
  tags = {
    Name = "mainVpc"
  }
}