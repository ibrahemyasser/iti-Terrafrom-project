variable "vpc_id" {
    description = "The ID of the VPC where the subnet will be created"
    type        = string
}
variable "subnets" {
  description = "List of subnets to create"
  type = list(object({
    name          = string
    cidr_block    = string
    map_public_ip = bool
    type          = string 
    az           = string
  }))
}