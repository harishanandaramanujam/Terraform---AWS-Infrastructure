# Terraform---AWS-Infrastructure
Terraform files for creating an AWS infrastructure from scratch

As a Graduate student of Northeastern University, I tried to create a replica of an on-premise Datacenter on AWS Cloud with features available on Terraform.
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

variable.tf contains all the necessary variables such as AWS Regions, CIDR blocks, etc. that supports main.tf to execute properly. This gives a free-hand to the user have their own attributes in place.

After cloning the repository follow these steps to get it running.
- "terraform init" from the folder will install all the necessary plugins for Terraform.
- "terraform plan" is used to create an execution plan.
- "terraform apply" will create the necessary infrastructure on the Cloud.
- "terraform destroy" will destroy all the resources created by terraform files in that directory.
