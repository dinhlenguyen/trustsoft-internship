# 🚀 Trustsoft Internship - Terraform AWS Infrastructure

This project provisions a full AWS infrastructure using **Terraform**, including:

- VPC with Public and Private Subnets (across two AZs)
- Internet Gateway and NAT Gateway
- Security Groups for ALB and EC2
- Two EC2 Instances in private subnets (Nginx/Apache installed with different web pages)
- Application Load Balancer (ALB) distributing traffic to both EC2s
- Outputs for key resources

---

## 📦 Project Structure

```plaintext
ts-internship/
├── providers.tf      # AWS provider configuration and Terraform settings
├── variables.tf      # Input variables for flexible configuration
├── outputs.tf        # Exposed resource outputs (VPC ID, Subnet IDs, ALB DNS, etc.)
├── vpc_sg.tf         # VPC, Subnets, NAT Gateway, Internet Gateway, Security Groups
├── ec2.tf            # EC2 Instances creation with different user-data scripts
├── alb.tf            # Application Load Balancer setup with target groups and listeners
```

## ⚙️ How to Deploy
#### 1. Clone the repository
```plaintext
git clone https://github.com/dinhlenguyen/trustsoft-internship.git
cd trustsoft-internship
```
#### 2. Initialize Terraform
```plaintext
terraform init
```
#### 3. Plan the infrastructure
```plaintext
terraform plan
```
#### 4. Apply the configuration
```plaintext
terraform apply
```
Confirm `yes` when prompted.

## 🌐 What Gets Created
- **VPC** with CIDR `10.0.0.0/16`
- **Public Subnets** (`10.0.101.0/24`, `10.0.102.0/24`)
- **Private Subnets** (`10.0.1.0/24`, `10.0.2.0/24`)
- **Internet Gateway** and **Single NAT Gateway**
- **Security Groups**:
  - **ALB SG**: allows inbound HTTP (port 80) from the internet
  - **Web EC2 SG**: allows inbound HTTP (port 80) only from ALB SG
- **EC2 Instances**:
  - Private only (no public IPs)
  - Each instance serves different web content (`Server A`, `Server B`) for testing Load Balancer behavior
- **Application Load Balancer**:
  - Round-robin distribution between the two EC2 instances

## 🛡️ Security Considerations
- **No SSH (port 22) open** to the internet.
- **EC2 instances** are private (reachable only through Load Balancer and outbound through NAT Gateway).
- **NAT Gateway** enables safe outbound internet access (for updates, patches, etc.).

## 📤 Outputs
After apply, Terraform will output:
- Load balancer DNS Name *- use this URL to access your web application! Don't forget to use http://.*

## 🛠️ Requirements
- Terraform CLI ≥ 1.3.0
- AWS CLI configured
- Git

## ✨ Author
- **Name:** Dinh Le Nguyen
- **Project:** Trustsoft Internship

## 📢 Notes

- The AMI ID (`ami_id`) must be correctly set for your region (`eu-west-1`).
- Load Balancer traffic alternates between EC2 instances (proving health checks and load balancing).
- The `.terraform.lock.hcl` file is committed for consistent provider versions.