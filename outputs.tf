output "VpcId" {
  value = module.vpc.vpc_id
}

output "instance_public_ip" {
  value = aws_instance.nginx.private_ip
}