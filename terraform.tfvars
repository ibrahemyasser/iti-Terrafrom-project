subnets = [
  {
    name          = "public-1"
    cidr_block    = "10.0.0.0/24"
    map_public_ip = true
    type          = "public"
    az            = "us-east-1a"
  },
  {
    name          = "public-2"
    cidr_block    = "10.0.2.0/24"
    map_public_ip = true
    type          = "public"
    az            = "us-east-1b"
  },
  {
    name          = "private-1"
    cidr_block    = "10.0.1.0/24"
    map_public_ip = false
    type          = "private"
    az            = "us-east-1a"
  },
  {
    name          = "private-2"
    cidr_block    = "10.0.3.0/24"
    map_public_ip = false
    type          = "private"
    az            = "us-east-1b"
  }
]
