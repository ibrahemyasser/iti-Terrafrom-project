data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] 

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

module "vpc" {
  source = "./vpc"
  vpc_cidr = var.vpc_cidr
}

module "subnet" {
  source = "./subnet"
  vpc_id = module.vpc.vpc_id
  subnets = var.subnets
}
module "igw" {
  source            = "./igw"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.subnet.public_subnet_ids
}
module "nat" {
    source               = "./nat"
    vpc_id               = module.vpc.vpc_id
    public_subnet_id    = module.subnet.public_subnet_ids[0]
    private_subnet_ids   = module.subnet.private_subnet_ids
}
module "security" {
  source = "./security"
  vpc_id = module.vpc.vpc_id
}
module "ec2-public" {
  source            = "./ec2"
  ami_id            = data.aws_ami.ubuntu.id
  key_name          = var.key-name
  vpc_id           = module.vpc.vpc_id
  security_group_ids = [module.security.sg_id]
    #   private_lb_dns    = module.lbs.lb_dns_names["private-lb"]
  bastion_host = null

  instances = [
    { name = "public-proxy-1", subnet_id = module.subnet.subnet_ids["public-1"], role = "public-proxy", instance_type = "t2.micro" },
    { name = "public-proxy-2", subnet_id = module.subnet.subnet_ids["public-2"], role = "public-proxy", instance_type = "t2.micro" },
 ]
}

module "ec2-private" {
  source            = "./ec2"
  ami_id            = data.aws_ami.ubuntu.id
  key_name          = var.key-name
  vpc_id           = module.vpc.vpc_id
  security_group_ids = [module.security.sg_id]
    #   private_lb_dns    = module.lbs.lb_dns_names["private-lb"]
  bastion_host = module.ec2-public.public_proxy_ips[0]

  instances = [
    { name = "private-app-1", subnet_id = module.subnet.subnet_ids["private-1"], role = "private-app", instance_type = "t2.micro" },
    { name = "private-app-2", subnet_id = module.subnet.subnet_ids["private-2"], role = "private-app", instance_type = "t2.micro" }
  ]
}
module "lbs" {
  source             = "./lb"
  vpc_id             = module.vpc.vpc_id
  security_group_ids = [module.security.sg_id]

  load_balancers = [
    {
      name                = "public-lb"
      internal            = false
      subnet_ids          = module.subnet.public_subnet_ids
      target_instance_ids = module.ec2-public.public_proxy_ids
    },
    {
      name                = "private-lb"
      internal            = true
      subnet_ids          = module.subnet.private_subnet_ids
      target_instance_ids = module.ec2-private.private_app_ids
    }
  ]
}

resource "null_resource" "configure_nginx" {
  count = length(module.ec2-public.public_proxy_ips)

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./${var.key-name}.pem")
    host        = module.ec2-public.public_proxy_ips[count.index]
  }

  provisioner "remote-exec" {
    inline = [
      <<-EOT
sudo bash -lc 'cat > /etc/nginx/sites-available/default <<EOF
server {
  listen 80;
  server_name _;

  location / {
    proxy_pass http://${module.lbs.lb_dns_names["private-lb"]};
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
  }
}
EOF'
EOT
      ,
      "sudo nginx -t",
      "sudo systemctl restart nginx"
    ]
  }

  depends_on = [module.ec2-public, module.ec2-private, module.lbs]
}