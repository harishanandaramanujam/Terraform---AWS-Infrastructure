# Declaring the Region
provider "aws" {
  region = "${var.aws_region}"
}

# VPC creation will also create Main Route Table, NACL, and DHCP options
resource "aws_vpc" "northeastern" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "Northeastern VPC"
  }
}

# Creates Internet Gateway
resource "aws_internet_gateway" "northeastern" {
    vpc_id = "${aws_vpc.northeastern.id}"

    tags = {
    Name = "Northeastern Internet Gateway"
  }
}



#Creating Security Groups
resource "aws_security_group" "Postfixserver" {
    name = "Postfixserver"
    description = "Allow 22,25,53,80,443,587,993,995"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 25
        to_port = 25
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 53
        to_port = 53
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 53
        to_port = 53
        protocol = "udp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 587
        to_port = 587
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 993
        to_port = 993
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 995
        to_port = 995
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    egress {
        from_port = -1 # -1 represents any port
        to_port = -1
        protocol = "0" # 0 represents all protocol
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Postfixserver"
    }
}

resource "aws_security_group" "WideOpen" {
    name = "WideOpen"
    description = "Allow Everything"

    ingress {
        from_port = -1 
        to_port = -1
        protocol = "0" 
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    egress {
        from_port = -1
        to_port = -1
        protocol = "0" 
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "WideOpen"
    }
}

resource "aws_security_group" "WebServer" {
    name = "WebServer"
    description = "Allow 22,80,443"

    ingress {
        from_port = 22 
        to_port = 22
        protocol = "tcp" 
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80 
        to_port = 80
        protocol = "tcp" 
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 443 
        to_port = 443
        protocol = "tcp" 
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    egress {
        from_port = -1
        to_port = -1
        protocol = "0" 
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "WebServer"
    }
}

# Keypair for EC2 instance
resource "aws_key_pair" "enckey" {
  key_name   = "enckey"
  public_key = "****" # EC2 SSH key
}



#Creating EC2Instance.................
resource "aws_instance" "Postfixserver" {
    ami = "ami-07c1207a9d40bc3bd"  #Default Ubuntu AMI
    availability_zone = "us-east-1a"
    instance_type = "t2.medium"
    key_name = "${aws_key_pair.enckey}"
    vpc_security_group_ids = ["${aws_security_group.Postfixserver.id}"]
    subnet_id = "${aws_subnet.us-east-1a-public-1.id}"
    associate_public_ip_address = false # As we need to associate Elastic IP (With port 25 unblocked)
    tags = {
        Name = "Postfixserver"
    }
}
resource "aws_instance" "nat" {
    ami = "ami-30913f47" # this is a special ami preconfigured to do NAT
    availability_zone = "us-east-1a"
    instance_type = "t2.small"
    key_name = "${aws_key_pair.enckey}"
    vpc_security_group_ids = ["${aws_security_group.WideOpen.id}"]
    subnet_id = "${aws_subnet.us-east-1a-public-2.id}"
    associate_public_ip_address = true
    source_dest_check = false
    tags = {
        Name = "NAT Instance"
    }
}
resource "aws_instance" "RocketChat" {
    ami = "ami-07c1207a9d40bc3bd" 
    availability_zone = "us-east-1a"
    instance_type = "t2.small"
    key_name = "${aws_key_pair.enckey}"
    vpc_security_group_ids = ["${aws_security_group.WideOpen.id}"]
    subnet_id = "${aws_subnet.us-east-1a-private-1-1.id}"
    associate_public_ip_address = true
    tags = {
        Name = "RocketChat"
    }
}





#Creating Public Subnets, Route table and Subnet Association
resource "aws_subnet" "us-east-1a-public-1" {
    vpc_id = "${aws_vpc.northeastern.id}"
    cidr_block = "${var.public_subnet_one}"
    availability_zone = "us-east-1a"
    tags = {
        Name = "Public Subnet 1"
    }
}

resource "aws_route_table" "us-east-1a-public-1" {
    vpc_id = "${aws_vpc.northeastern.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.northeastern.id}"
    }
    tags = {
        Name = "Public Subnet 1"
    }
}

resource "aws_route_table_association" "us-east-1a-public-1" {
    subnet_id = "${aws_subnet.us-east-1a-public-1.id}"
    route_table_id = "${aws_route_table.us-east-1a-public-1.id}"
}

resource "aws_subnet" "us-east-1a-public-2" {
    vpc_id = "${aws_vpc.northeastern.id}"
    cidr_block = "192.168.2.0/24"
    availability_zone = "us-east-1a"
    tags = {
        Name = "Public Subnet 2"
    }
}

resource "aws_route_table" "us-east-1a-public-2" {
    vpc_id = "${aws_vpc.northeastern.id}"
    route {
        cidr_block = "${var.public_subnet_two}"
        gateway_id = "local"
    }
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.northeastern.id}"
    }
    tags = {
        Name = "Public Subnet 2"
    }
}

resource "aws_route_table_association" "us-east-1a-public-2" {
    subnet_id = "${aws_subnet.us-east-1a-public-2.id}"
    route_table_id = "${aws_route_table.us-east-1a-public-2.id}"
}




#Creating Private subnet, Route table and Subnet Association
resource "aws_subnet" "us-east-1a-private-1" {
    vpc_id = "${aws_vpc.northeastern.id}"
    cidr_block = "${var.private_subnet_one}"
    availability_zone = "us-east-1a"
    tags = {
        Name = "Private Subnet 1"
    }
}

resource "aws_route_table" "us-east-1a-private-1" {
    vpc_id = "${aws_vpc.northeastern.id}"
    route {
        cidr_block = "0.0.0.0/0"
        instance_id = "${aws_instance.nat.id}"
    }
    tags = {
        Name = "Private Subnet 1"
    }
}

resource "aws_route_table_association" "a" {
    subnet_id = "${aws_subnet.us-east-1a-private-1.id}"
    route_table_id = "${aws_route_table.us-east-1a-private-1.id}"
}

resource "aws_subnet" "us-east-1a-private-2" {
    vpc_id = "${aws_vpc.northeastern.id}"
    cidr_block = "${var.private_subnet_two}"
    availability_zone = "us-east-1a"
    tags = {
        Name = "Private Subnet 1"
    }
}

resource "aws_route_table" "us-east-1a-private-2" {
    vpc_id = "${aws_vpc.northeastern.id}"
    route {
        cidr_block = "0.0.0.0/0"
        instance_id = "${aws_instance.nat.id}"
    }
    tags = {
        Name = "Private Subnet 1"
    }
}

resource "aws_route_table_association" "b" {
    subnet_id = "${aws_subnet.us-east-1a-private-2.id}"
    route_table_id = "${aws_route_table.us-east-1a-private-2.id}"
}



# Private Subnet for Directory ans Workspace. To Restrict internet access default route is not enabled
resource "aws_subnet" "us-east-1a-private-3" {
    vpc_id = "${aws_vpc.northeastern.id}"
    cidr_block = "${var.private_subnet_three}"
    availability_zone = "us-east-1a"
    tags = {
        Name = "Private Subnet 3"
    }
}

resource "aws_route_table" "us-east-1a-private-3" {
    vpc_id = "${aws_vpc.northeastern.id}"
    tags = {
        Name = "Private Subnet 3"
    }
}

resource "aws_route_table_association" "c" {
    subnet_id = "${aws_subnet.us-east-1a-private-3.id}"
    route_table_id = "${aws_route_table.us-east-1a-private-3.id}"
}

resource "aws_subnet" "us-east-1a-private-4" {
    vpc_id = "${aws_vpc.northeastern.id}"
    cidr_block = "${var.private_subnet_four}"
    availability_zone = "us-east-1b" # Directory requries 2 subnets in different Availablity Zones
    tags = {
        Name = "Private Subnet 4"
    }
}

resource "aws_route_table" "us-east-1a-private-4" {
    vpc_id = "${aws_vpc.northeastern.id}"
    tags = {
        Name = "Private Subnet 4"
    }
}

resource "aws_route_table_association" "d" {
    subnet_id = "${aws_subnet.us-east-1a-private-4.id}"
    route_table_id = "${aws_route_table.us-east-1a-private-4.id}"
}



# Allocation Elastic IP for Postfixserver Server
resource "aws_eip" "lb" {
  instance = "${aws_instance.Postfixserver.id}"
  vpc      = true
}



# Creating Microsoft managed Active Directories
resource "aws_directory_service_directory" "admin" {
  name     = "admin.northeastern.us"
  password = "SuperSecretPassw0rd"
  edition  = "Standard"
  type     = "MicrosoftAD"

  vpc_settings {
    vpc_id     = "${aws_vpc.northeastern.id}"
    subnet_ids = ["${aws_subnet.us-east-1a-private-3.id}", "${aws_subnet.us-east-1a-private-4.id}"]
  }

  tags = {
    Project = "Admin Directory"
  }
}

resource "aws_directory_service_directory" "user" {
  name     = "user.northeastern.us"
  password = "SuperSecretPassw0rd"
  edition  = "Standard"
  type     = "MicrosoftAD"

  vpc_settings {
    vpc_id     = "${aws_vpc.northeastern.id}"
    subnet_ids = ["${aws_subnet.us-east-1a-private-3.id}", "${aws_subnet.us-east-1a-private-4.id}"]
  }

  tags = {
    Project = "User Directory"
  }
}



#Registering Workspace with Directory
resource "aws_workspaces_directory" "admin" {
  directory_id = "${aws_directory_service_directory.admin.id}"

  self_service_permissions {
    increase_volume_size = true
    rebuild_workspace    = true
  }
}

resource "aws_workspaces_directory" "user" {
  directory_id = "${aws_directory_service_directory.user.id}"

  self_service_permissions {
    increase_volume_size = true
    rebuild_workspace    = true
  }
}



# Creating Workspace
resource "aws_workspaces_workspace" "secureadmin1" {
  directory_id = "${aws_workspaces_directory.admin.id}"
  bundle_id    = "wsb-bh8rsxt14" # Default Windows10 OS (English)
  user_name    = "secureadmin1" #username should be in Active Directory already

  root_volume_encryption_enabled = true
  user_volume_encryption_enabled = true
  volume_encryption_key          = "alias/aws/workspaces"

  workspace_properties {
    compute_type_name                         = "VALUE"
    user_volume_size_gib                      = 50
    root_volume_size_gib                      = 80
    running_mode                              = "AUTO_STOP"
    running_mode_auto_stop_timeout_in_minutes = 60
  }

  tags = {
    Department = "Admin"
  }
}

resource "aws_workspaces_workspace" "secureuser1" {
  directory_id = "${aws_workspaces_directory.user.id}"
  bundle_id    = "wsb-bh8rsxt14" 
  user_name    = "secureuser1" 

  root_volume_encryption_enabled = true
  user_volume_encryption_enabled = true
  volume_encryption_key          = "alias/aws/workspaces"

  workspace_properties {
    compute_type_name                         = "VALUE"
    user_volume_size_gib                      = 10
    root_volume_size_gib                      = 80
    running_mode                              = "AUTO_STOP"
    running_mode_auto_stop_timeout_in_minutes = 60
  }

  tags = {
    Department = "Admin"
  }
}


#Creating Route53 Zones
resource "aws_route53_zone" "publiczone" {
  name = "northeastern.us"
}


resource "aws_route53_zone" "privatezone" {
  name = "northeastern.us"
  vpc {
    vpc_id = "${aws_vpc.northeastern.id}"
  }
}



#Generating VPC Flowlog and storing it in S3 bucket
resource "aws_s3_bucket" "VPCFlowlog" {
  bucket = "VPCFlowlog"
  tags = {
    Name = "VPCFlowlog"
  }
}

resource "aws_flow_log" "VPCcientFlowlog" {
  log_destination      = "${aws_s3_bucket.VPCFlowlog.arn}"
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = "${aws_vpc.northeastern.id}"
}



#Creating Cloud Watch for CPU utilization for Postfix Web server
resource "aws_cloudwatch_dashboard" "northeasternCloudWatch" {
  dashboard_name = "northeasternWatch"

  dashboard_body = <<EOF
 {
   "widgets": [
       {
          "type":"metric",
          "x":0,
          "y":0,
          "width":12,
          "height":6,
          "properties":{
             "metrics":[
                [
                   "AWS/EC2",
                   "CPUUtilization", 
                   "InstanceId",
                   "${aws_security_group.Postfixserver.id}"
                ]
             ],
             "period":300,
             "stat":"Average",
             "region":"us-east-1",
             "title":"EC2 Instance CPU"
          }
       },
       {
          "type":"text",
          "x":0,
          "y":7,
          "width":3,
          "height":3,
          "properties":{
             "markdown":"First Dashboard"
          }
       }
   ]
 }
 EOF
}