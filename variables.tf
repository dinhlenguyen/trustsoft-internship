########################################
# General Settings
########################################

variable "aws_region" {
  description = "AWS Region to deploy into"
  type        = string
  default     = "eu-west-1" # Ireland
}

########################################
# VPC Settings
########################################

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

########################################
# Subnet Settings
########################################

# Public Subnets
variable "public_subnet_cidr_a" {
  description = "CIDR block for Public Subnet A"
  type        = string
  default     = "10.0.101.0/24"
}

variable "public_subnet_cidr_b" {
  description = "CIDR block for Public Subnet B"
  type        = string
  default     = "10.0.102.0/24"
}

# Private Subnets
variable "private_subnet_cidr_a" {
  description = "CIDR block for Private Subnet A"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr_b" {
  description = "CIDR block for Private Subnet B"
  type        = string
  default     = "10.0.2.0/24"
}

########################################
# AZ Settings
########################################

variable "availability_zone_a" {
  description = "Availability Zone for Subnet A"
  type        = string
  default     = "eu-west-1a"
}

variable "availability_zone_b" {
  description = "Availability Zone for Subnet B"
  type        = string
  default     = "eu-west-1b"
}

########################################
# EC2 Settings
########################################

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-0ce8c2b29fcc8a346"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "user_data_script" {
  description = "User data script to bootstrap EC2 instances"
  type        = string
  default     = ""
}

########################################
# User Data Scripts
########################################

variable "user_data_script_a" {
  description = "User data for EC2 Instance A"
  type        = string
  default     = <<-EOF
                #!/bin/bash
                yum update -y
                yum install -y mariadb amazon-cloudwatch-agent nginx
                systemctl start nginx
                systemctl enable nginx
                echo "<h1>Welcome to Server A - Internship Dinh</h1>" > /usr/share/nginx/html/index.html

                # Create CloudWatch config file
                cat << EOC > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
                {
                  "agent": {
                    "metrics_collection_interval": 60,
                    "run_as_user": "root"
                  },
                  "metrics": {
                    "append_dimensions": {
                      "AutoScalingGroupName": "\${aws:AutoScalingGroupName}",
                      "ImageId": "\${aws:ImageId}",
                      "InstanceId": "\${aws:InstanceId}",
                      "InstanceType": "\${aws:InstanceType}"
                    },
                    "metrics_collected": {
                      "cpu": {
                        "measurement": [
                          "cpu_usage_idle",
                          "cpu_usage_user",
                          "cpu_usage_system"
                        ],
                        "metrics_collection_interval": 60,
                        "totalcpu": true
                      },
                      "disk": {
                        "measurement": ["used_percent"],
                        "metrics_collection_interval": 60,
                        "resources": ["*"]
                      },
                      "mem": {
                        "measurement": ["mem_used_percent"],
                        "metrics_collection_interval": 60
                      }
                    }
                  }
                }
                EOC

                # Start CloudWatch Agent
                /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
                  -a fetch-config \
                  -m ec2 \
                  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
                  -s
                EOF
}

variable "user_data_script_b" {
  description = "User data for EC2 Instance B"
  type        = string
  default     = <<-EOF
                #!/bin/bash
                yum update -y
                yum install -y mariadb amazon-cloudwatch-agent nginx
                systemctl start nginx
                systemctl enable nginx
                echo "<h1>Welcome to Server B - Internship Dinh</h1>" > /usr/share/nginx/html/index.html

                # Create CloudWatch config file
                cat << EOC > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
                {
                  "agent": {
                    "metrics_collection_interval": 60,
                    "run_as_user": "root"
                  },
                  "metrics": {
                    "append_dimensions": {
                      "AutoScalingGroupName": "\${aws:AutoScalingGroupName}",
                      "ImageId": "\${aws:ImageId}",
                      "InstanceId": "\${aws:InstanceId}",
                      "InstanceType": "\${aws:InstanceType}"
                    },
                    "metrics_collected": {
                      "cpu": {
                        "measurement": [
                          "cpu_usage_idle",
                          "cpu_usage_user",
                          "cpu_usage_system"
                        ],
                        "metrics_collection_interval": 60,
                        "totalcpu": true
                      },
                      "disk": {
                        "measurement": ["used_percent"],
                        "metrics_collection_interval": 60,
                        "resources": ["*"]
                      },
                      "mem": {
                        "measurement": ["mem_used_percent"],
                        "metrics_collection_interval": 60
                      }
                    }
                  }
                }
                EOC

                # Start CloudWatch Agent
                /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
                  -a fetch-config \
                  -m ec2 \
                  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
                  -s
                EOF
}

########################################
# SNS settings
########################################
variable "notification_emails" {
  description = "List of email addresses to notify for CloudWatch alarms"
  type        = list(string)
  default     = ["lend03@vse.cz"]
}

########################################
# RDS settings
########################################
variable "db_password" {
  type      = string
  sensitive = true
}