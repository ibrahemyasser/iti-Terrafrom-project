output "subnet_ids" {
  value = { for k, s in aws_subnet.modular_subnet : k => s.id }
}

output "public_subnet_ids" {
  value = [
    for k, s in aws_subnet.modular_subnet : s.id if s.tags.Type == "public"
  ]
}

output "private_subnet_ids" {
  value = [
    for k, s in aws_subnet.modular_subnet : s.id if s.tags.Type == "private"
  ]
}
