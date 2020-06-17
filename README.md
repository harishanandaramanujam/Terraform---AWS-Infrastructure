# Terraform---AWS-Infrastructure
Terraform files for creating a AWS infrastructure from scratch

As a Graduate student of Northeastern university, I tried to create a replica of on-premise Datacenter on AWS Cloud with features available on Terraform.
The main.tf file contains code to build the following in an AWS infrastructure.
- VPC
- Public Subnets
- Private Subnets
- RouteTables
- Internet Gateway
- EC2 instance
- Security Groups
- Keypair
- Elastic IP
- Microsoft Managed Active Directories
- Workspace
- Route53 Zones
- CloudWatch

variable.tf contains all the necessary variables such as AWS Regions, CIDR blocks, etc. that supports main.tf to execute properly. This gives a free-hand to user have their own attributes in place.
