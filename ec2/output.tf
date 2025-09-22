output "instance_ids" {
  value = { for k, inst in aws_instance.this : k => inst.id }
}

output "public_ips" {
  value = { for k, inst in aws_instance.this : k => inst.public_ip if inst.public_ip != "" }
}

output "private_ips" {
  value = { for k, inst in aws_instance.this : k => inst.private_ip }
}
