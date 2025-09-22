variable "vpc_id" {
  description = "The ID of the VPC to attach the Internet Gateway to"
  type        = string
  
}
variable "public_subnet_id" {
  type = string
}
variable "private_subnet_ids" {
  type = list(string)
}
