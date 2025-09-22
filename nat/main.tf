resource "aws_eip" "eip" {
  domain   = "vpc"
  tags = { Name = "nat-eip" }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = var.public_subnet_id
  tags = { Name = "natgateway" }
}
resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = { Name = "private-rt" }
}
resource "aws_route_table_association" "private_assoc" {
  for_each = { for idx, subnet_id in var.private_subnet_ids : idx => subnet_id }

  subnet_id      = each.value
  route_table_id = aws_route_table.private.id
}