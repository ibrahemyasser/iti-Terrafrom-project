variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
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

variable "key-name" {
  description = "The name of the SSH key pair"
  type        = string
  default     = "test-key-pair"
  
}