resource "aws_internet_gateway" "igw" {
    vpc_id = var.vpc_id
    
    tags = {
        Name = "main_igw"
    }
}

resource "aws_route_table" "public_rt" {
    vpc_id = var.vpc_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

  tags = { Name = "public-rt" }
}

resource "aws_route_table_association" "public_assoc" {
  for_each = { for idx, subnet_id in var.public_subnet_ids : idx => subnet_id }

  subnet_id      = each.value
  route_table_id = aws_route_table.public_rt.id
}
