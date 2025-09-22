variable "instances" {
  type = list(object({
    name          = string
    subnet_id     = string   # specify the exact subnet
    role          = string   # "public-proxy" or "private-app"
    instance_type = string
  }))
}

variable "ami_id" {
  type = string
}

variable "key_name" {
  type = string
}
variable "bastion_host" {
  type = string
  description = "Public IP of bastion (first public proxy instance)"
}
variable "vpc_id" {
  type = string
}
variable "security_group_ids" {
  type = list(string)
}

# variable "private_lb_dns" {
#   description = "DNS name of private load balancer (for proxy config)"
#   type        = string
# }