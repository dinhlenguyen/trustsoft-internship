provider "aws" {
  region = "eu-west-1"           # Ireland
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "vpc-internship-dinh"
  cidr = "10.0.0.0/16"

  azs = ["eu-west-1a", "eu-west-1b"]

  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  private_subnets = ["10.0.1.0/24",   "10.0.2.0/24"]

  # ── per-AZ Name tags (now correct type) ──────────
  public_subnet_tags_per_az = {
    eu-west-1a = { Name = "public_subnet_internship_dinh_a" }
    eu-west-1b = { Name = "public_subnet_internship_dinh_b" }
  }

  private_subnet_tags_per_az = {
    eu-west-1a = { Name = "private_subnet_internship_dinh_a" }
    eu-west-1b = { Name = "private_subnet_internship_dinh_b" }
  }

  enable_nat_gateway  = true
  single_nat_gateway  = true
}
