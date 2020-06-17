variable "aws_region" {
    description = "Region for the VPC"
    default = "us-east-1"
}


variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "192.168.0.0/16"
}

variable "public_subnet_one" {
    description = "CIDR for the Public Subnet"
    default = "192.168.1.0/24"
}

variable "public_subnet_two" {
    description = "CIDR for the Public Subnet"
    default = "192.168.2.0/24"
}

variable "private_subnet_one" {
    description = "CIDR for the Private Subnet"
    default = "192.168.11.0/24"
}

variable "private_subnet_two" {
    description = "CIDR for the Private Subnet"
    default = "192.168.12.0/24"
}

variable "private_subnet_three" {
    description = "CIDR for the Private Subnet"
    default = "192.168.13.0/24"
}

variable "private_subnet_four" {
    description = "CIDR for the Private Subnet"
    default = "192.168.14.0/24"
}

