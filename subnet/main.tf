resource "aws_subnet" "modular_subnet" {
  for_each = { for s in var.subnets : s.name => s }

  vpc_id                  = var.vpc_id
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = each.value.map_public_ip
  availability_zone       = lookup(each.value, "az", null)

  tags = {
    Name = each.value.name
    Type = each.value.type
  }
}