output "lb_dns_names" {
  value = { for k, lb in aws_lb.this : k => lb.dns_name }
}
