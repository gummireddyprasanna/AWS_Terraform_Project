# Get Availability Zones

data "aws_availability_zones" "available" {
  state = "available"
}


# VPC 

resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "My-VPC"
  }

}

# Public Subnets 

resource "aws_subnet" "public_subnets" {
  count                   = 2
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_${count.index + 1}"
  }

}

# Private Subnets


resource "aws_subnet" "private_subnets" {
  count             = 2
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "private_subnet_${count.index + 1}"
  }

}

# Internet Gateway

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "My-IGW"
  }

}

# Elastic IP needed for NAT Gateway

resource "aws_eip" "my_eip_nat" {
  tags = {
    Name = "My-EIP for NAT"
  }

}

# NAT Gateway inside the first public subnet


resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.my_eip_nat.id
  subnet_id     = aws_subnet.public_subnets[0].id
  tags = {
    Name = "My-NAT-GW"
  }

}

# Public Route Table 

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
    Name = "Public-Route"
  }

}

# Public Route Table Association

resource "aws_route_table_association" "public_assos" {
  count          = 2
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route.id

}

# Private Route Table

resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_nat_gateway.id
  }
  tags = {
    Name = "Private-Route"
  }

}

# Private Route Table Association

resource "aws_route_table_association" "private_assos" {
  count          = 2
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route.id

}


# Launch template for EC2 public - Autoscaling

resource "aws_launch_template" "public_template_ec2" {
  name          = "public_template_ec2"
  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.public_sg.id]
  }
  user_data = base64encode(file("userdata_web_servers.sh"))
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "public_instance_ec2"
    }
  }

  tags = {
    Name = "public_template_ec2"
  }
}

# Launch template for private instances in Auto Scaling Group
resource "aws_launch_template" "private_template_ec2" {
  name          = "private_template_ec2"
  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.private_sg.id]
  }
  
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "private_instance_ec2"
    }
  }

  tags = {
    Name = "private_template_ec2"
  }
}

# Security group for public instances in Auto-Scaling-Group

resource "aws_security_group" "public_sg" {
  vpc_id      = aws_vpc.my_vpc.id
  description = "Allow SSH, HTTP, HTTPS, AllICMP inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Outbound rule to allow all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 indicates all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public_sg"
  }
}

# Security group for private instances in Auto-Scaling-Group

resource "aws_security_group" "private_sg" {
  vpc_id      = aws_vpc.my_vpc.id
  description = "Allow only SSH inbound from within VPC"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Use VPC CIDR range for internal SSH access only
  }

  tags = {
    Name = "private_sg"
  }
  # Outbound rule to allow all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 indicates all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Autoscaling group for public instances

resource "aws_autoscaling_group" "public_asg" {
  launch_template {
    id      = aws_launch_template.public_template_ec2.id
    version = "$Latest"
  }

  vpc_zone_identifier = [
    aws_subnet.public_subnets[0].id,
    aws_subnet.public_subnets[1].id
  ]
  min_size                  = 2
  max_size                  = 4
  desired_capacity          = 2
  health_check_type         = "EC2"
  health_check_grace_period = 300

  lifecycle {
    create_before_destroy = true
  }
}

# Autoscaling group for private instances

resource "aws_autoscaling_group" "private_asg" {
  launch_template {
    id      = aws_launch_template.private_template_ec2.id
    version = "$Latest"
  }

  vpc_zone_identifier = [
    aws_subnet.private_subnets[0].id,
    aws_subnet.private_subnets[1].id
  ]
  min_size                  = 2
  max_size                  = 4
  desired_capacity          = 2
  health_check_type         = "EC2"
  health_check_grace_period = 300

  lifecycle {
    create_before_destroy = true
  }
}

# Application Load Balancer
resource "aws_lb" "public_alb" {
  name               = "public-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_alb_sg.id]                              # Security group for ALB
  subnets            = [aws_subnet.public_subnets[0].id, aws_subnet.public_subnets[1].id] # Place in public subnets

  enable_deletion_protection = false

  tags = {
    Name = "public_alb"
  }
}

# Security group for ALB to allow inbound HTTP/HTTPS traffic
resource "aws_security_group" "public_alb_sg" {
  vpc_id      = aws_vpc.my_vpc.id
  description = "Allow inbound HTTP and HTTPS for ALB"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public_alb_sg"
  }
}

# Target Group for public instances
resource "aws_lb_target_group" "public_tg" {
  name        = "public-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.my_vpc.id
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "public_tg"
  }
}

# Listener for ALB to forward traffic to target group
resource "aws_lb_listener" "public_http_listener" {
  load_balancer_arn = aws_lb.public_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public_tg.arn
  }
}

# Associate Auto Scaling Group with Target Group for ALB
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.public_asg.name
  lb_target_group_arn    = aws_lb_target_group.public_tg.arn
}
