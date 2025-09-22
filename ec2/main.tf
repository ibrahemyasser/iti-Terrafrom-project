resource "aws_instance" "this" {
  for_each = { for inst in var.instances : inst.name => inst }

  ami                    = var.ami_id
  instance_type          = each.value.instance_type
  subnet_id              = each.value.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name

  tags = { 
    Name = each.value.name 
    Role = each.value.role  
  }

  # Connection logic
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./${var.key_name}.pem")

    # If public → connect directly
    # If private → connect via bastion (first public proxy instance)
    host          = each.value.role == "public-proxy" ? self.public_ip : self.private_ip
    bastion_host  = each.value.role == "private-app" ? var.bastion_host : null
    bastion_user  = each.value.role == "private-app" ? "ubuntu" : null
    bastion_private_key = each.value.role == "private-app" ? file("./${var.key_name}.pem") : null
  }

  # Install software depending on role
  provisioner "remote-exec" {
  inline = each.value.role == "public-proxy" ? [
    # Public Proxy EC2s → Install NGINX
    "sudo apt-get update -y",
    "sudo apt-get install -y nginx",
    "sudo systemctl enable nginx",
    "echo '<h1>Proxy placeholder $(hostname -f)</h1>' | sudo tee /var/www/html/index.nginx-debian.html",
    "sudo systemctl restart nginx"
  ] : [
    # Private App EC2s → Install Apache with better error handling
    "sudo apt-get update -y",
    "sudo apt-get clean",  # Clear package cache
    "sudo apt-get update -y",  # Update again
    "sudo apt-get install -y --fix-broken",  # Fix any broken packages
    "sudo apt-get install -y apache2 || sudo apt-get install -y apache2 --fix-missing",  # Retry if needed
    "sudo systemctl enable apache2",
    "sudo mkdir -p /var/www/html",  # Ensure directory exists
    "echo \"<h1>Hello from ${each.value.name}</h1>\" | sudo tee /var/www/html/index.html",
    "sudo systemctl restart apache2"
  ]
}

  # Collect IPs locally
  provisioner "local-exec" {
    command = "echo ${each.value.role} ${each.value.name} ${self.public_ip != "" ? self.public_ip : self.private_ip} >> all-ips.txt"
  }
}

output "public_proxy_ids" {
  value = [for inst in aws_instance.this : inst.id if inst.tags["Role"] == "public-proxy"]
}

output "private_app_ids" {
  value = [for inst in aws_instance.this : inst.id if inst.tags["Role"] == "private-app"]
}
output "public_proxy_ips" {
  value = [for inst in aws_instance.this : inst.public_ip if inst.tags["Role"] == "public-proxy"]
}