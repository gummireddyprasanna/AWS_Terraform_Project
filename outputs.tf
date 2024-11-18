output "vpc_id" {
  value       = aws_vpc.my_vpc.id
  description = "The ID of the VPC"
}

output "public_subnet_ids" {
  value       = aws_subnet.public_subnets[*].id
  description = "The IDs of the public subnets"
}

output "private_subnet_ids" {
  value       = aws_subnet.private_subnets[*].id
  description = "The IDs of the private subnets"
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.my_igw.id
  description = "The ID of the Internet Gateway"
}

output "nat_gateway_id" {
  value       = aws_nat_gateway.my_nat_gateway.id
  description = "The ID of the NAT Gateway"
}

output "public_lb_dns_name" {
  value       = aws_lb.public_alb.dns_name
  description = "The DNS name of the public Application Load Balancer"
}

output "public_asg_name" {
  value       = aws_autoscaling_group.public_asg.name
  description = "The name of the public Auto Scaling Group"
}

output "public_sg_id" {
  value       = aws_security_group.public_sg.id
  description = "The ID of the public security group"
}

output "public_launch_template_id" {
  value       = aws_launch_template.public_template_ec2.id
  description = "The ID of the public EC2 launch template"
}
