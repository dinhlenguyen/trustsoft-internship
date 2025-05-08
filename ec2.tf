########################################
# EC2 Instances (Merged with for_each)
########################################

resource "aws_instance" "web_instances" {
  for_each = {
    web_a = {
      subnet_id = aws_subnet.private_subnet_a.id
      name      = "ec2_web_a_internship_dinh"
    },
    web_b = {
      subnet_id = aws_subnet.private_subnet_b.id
      name      = "ec2_web_b_internship_dinh"
    }
  }

  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = each.value.subnet_id
  vpc_security_group_ids      = [aws_security_group.web_internship_dinh.id]
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile_internship_dinh.name

  tags = {
    Name        = each.value.name
    Environment = "Dev"
  }

  user_data = var.user_data_script
}