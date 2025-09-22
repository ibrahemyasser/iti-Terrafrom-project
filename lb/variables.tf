variable "load_balancers" {
  type = list(object({
    name                = string
    internal            = bool
    subnet_ids          = list(string)
    target_instance_ids = list(string)
  }))
}

variable "security_group_ids" {
  type = list(string)
}
variable "vpc_id" {
  type = string
}