variable "vpc_cidr" {
    description = "CIDR block for the VPC"
    type = string
  
}

variable "public_subnet_cidrs" {
    description = "CIDR block for the public subnets"
    type = list(string)
  
}

variable "private_subnet_cidrs" {
    description = "CIDR block for the private subnets"
    type = list(string)
  
} 

variable "ami" {
    description = "AMI for the EC2 instances"
    type = string
  
}

variable "instance_type" {
    description = "Instance type for the EC2 instances"
    type = string
  
}

variable "key_name" {
    description = "Key name for the EC2 instances"
    type = string
  
}
  
