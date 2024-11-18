# AWS Infrastructure with Terraform

This Terraform configuration sets up a scalable, secure, and high-availability infrastructure on AWS. It includes a Virtual Private Cloud (VPC) with subnets, security groups, an Internet Gateway, NAT Gateway, Auto Scaling groups, and an Application Load Balancer with associated resources.

## Table of Contents
- [Architecture Overview](#architecture-overview)
- [Prerequisites](#prerequisites)
- [Configuration Files](#configuration-files)
- [Resources Created](#resources-created)
- [Usage](#usage)

## Architecture Overview

This configuration deploys:
1. **VPC**: A custom VPC with public and private subnets.
2. **Public and Private Subnets**: Two public and two private subnets across Availability Zones for high availability.
3. **Internet Gateway & NAT Gateway**: Internet Gateway for public access, NAT Gateway for private instances' internet access.
4. **Security Groups**: Custom security groups for public and private instances.
5. **Auto Scaling Groups**: Automatic scaling for both public and private EC2 instances.
6. **Application Load Balancer (ALB)**: Distributes incoming traffic to the public instances.

## Prerequisites

1. **AWS CLI**: Configure the AWS CLI with access keys. [Install AWS CLI](https://aws.amazon.com/cli/).
2. **Terraform**: Install Terraform version 0.12 or later. [Download Terraform](https://www.terraform.io/downloads.html).
3. **SSH Key Pair**: An AWS EC2 key pair for SSH access to instances. Specify this key pair name in the `terraform.tfvars` file.

## Configuration Files

This repository includes the following files for configuring the AWS infrastructure:

- `main.tf`: Defines all AWS resources and configurations.
- `variables.tf`: Contains input variables for the configuration, such as CIDR blocks, instance types, and other customizable parameters.
- `outputs.tf`: Specifies the outputs of the Terraform configuration, like the ALB DNS name.
- `terraform.tfvars`: Defines values for the variables, such as CIDR ranges, AMI IDs, and SSH key pair.
- `userdata_web_servers.sh`: A shell script for initializing EC2 instances with necessary setup commands (e.g., installing software, setting environment variables).

## Resources Created

### Networking
- **VPC**: A custom VPC with a specified CIDR block.
- **Public Subnets**: Two public subnets in separate Availability Zones.
- **Private Subnets**: Two private subnets in separate Availability Zones.
- **Internet Gateway**: Allows public internet access to the VPC.
- **NAT Gateway**: Enables internet access for instances in private subnets.

### Security Groups
- **Public Security Group**: Allows inbound SSH, HTTP, HTTPS, and ICMP access.
- **Private Security Group**: Restricts access to SSH traffic within the VPC only.
- **ALB Security Group**: Allows HTTP and HTTPS traffic to the Application Load Balancer.

### EC2 Launch Templates and Auto Scaling
- **Launch Templates**: Configures EC2 instances for public and private Auto Scaling groups.
- **Auto Scaling Groups**: Manages scaling of public and private EC2 instances for high availability.

### Load Balancer
- **Application Load Balancer (ALB)**: Distributes traffic across public instances.
- **Target Group**: Routes incoming requests to the instances in the public Auto Scaling Group.
- **Listener**: Forwards HTTP traffic from the ALB to the target group.

## Usage

1. Clone this repository:
   ```bash
   git clone https://github.com/your-repository.git
   cd your-repository
   ```

2. Update values in `terraform.tfvars` to configure CIDR blocks, instance types, AMI IDs, and SSH key pair.

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Plan and apply the configuration:
   ```bash
   terraform plan
   terraform apply
   ```

5. **Access the Outputs**: After a successful deployment, use the outputs specified in `outputs.tf` (such as the ALB DNS name) to access the infrastructure.

## Files and Customization

- **variables.tf**: Adjust network ranges, instance types, and other parameters as needed.
- **terraform.tfvars**: Contains specific values for each variable in `variables.tf`.
- **userdata_web_servers.sh**: Customize this script to specify software installations and configurations for your EC2 instances.

## Notes

- **Cleanup**: To avoid charges, run `terraform destroy` when you’re done.
- **Accessing Instances**: Use the SSH key specified in `terraform.tfvars` to connect to public EC2 instances.
- **User Data**: Modify `userdata_web_servers.sh` for additional bootstrapping commands on your EC2 instances.

---

This setup provides a robust, high-availability infrastructure suitable for deploying web applications on AWS using Terraform.
```

