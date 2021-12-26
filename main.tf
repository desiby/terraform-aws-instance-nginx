
# provider "aws" {
#   region                      = var.region
# }

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name           = "WebApp-${var.env}-vpc"
  cidr           = var.vpc_cidr
  azs            = ["us-west-1a"]
  public_subnets = [var.public_subnet_cidr] //use the cidersubnets() function
  tags = {
    Environment : "${var.env}-vpc"
  }
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "incoming http connections from the internet"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "traffic leaving server ex: go download pckge from somewhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http-${var.env}-sg"
  }
}

data "aws_ami" "amazon_linux_latest" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}


resource "aws_instance" "nginx" {
  ami           = data.aws_ami.amazon_linux_latest.id
  instance_type = var.instance_type
  subnet_id = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.allow_http.id]
  availability_zone = module.vpc.azs[0]
  associate_public_ip_address = true
  user_data = <<EOF
                #/bin/bash
                sudo yum update -y && sudo yum install -y docker
                sudo systemctl start docker
                sudo usermod -aG docker ec2-user
                docker run --name myNginx -p 8080:80 nginx
                docker exec -it myNginx bash
                echo "Hello World" > /usr/share/nginx/html/index.html
              EOF

  tags = var.tags
}
