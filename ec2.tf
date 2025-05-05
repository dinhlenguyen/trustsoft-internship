########################################
# EC2 Instances
########################################

# EC2 Instance A (Private Subnet A)
resource "aws_instance" "web_a_internship_dinh" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.private_subnet_a.id
  vpc_security_group_ids      = [aws_security_group.web_internship_dinh.id]
  associate_public_ip_address = false # Instance is private (NAT outbound)
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile_internship_dinh.name

  tags = {
    Name        = "ec2_web_a_internship_dinh"
    Environment = "Dev"
  }

  user_data = var.user_data_script_a
}

# EC2 Instance B (Private Subnet B)
resource "aws_instance" "web_b_internship_dinh" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.private_subnet_b.id
  vpc_security_group_ids      = [aws_security_group.web_internship_dinh.id]
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile_internship_dinh.name

  tags = {
    Name        = "ec2_web_b_internship_dinh"
    Environment = "Dev"
  }

  user_data = var.user_data_script_b
}
