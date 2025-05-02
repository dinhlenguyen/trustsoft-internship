########################################
# IAM Role for EC2 Systems Manager (SSM)
########################################

resource "aws_iam_role" "ssm_ec2_internship_dinh" {
  name = "ssm-ec2-role-internship-dinh"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "ssm-ec2-role-internship-dinh"
  }
}

########################################
# IAM Policy Attachment
# Attach the AWS Managed Policy for SSM access
########################################

resource "aws_iam_role_policy_attachment" "ssm_attach_internship_dinh" {
  role       = aws_iam_role.ssm_s3_internship_dinh.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

########################################
# Attach S3 Full Access Managed Policy
########################################

resource "aws_iam_role_policy_attachment" "ssm_s3_full_access" {
  role       = aws_iam_role.ssm_s3_internship_dinh.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

########################################
# IAM Instance Profile
# Needed to attach IAM Role to EC2 Instances
########################################

resource "aws_iam_instance_profile" "ssm_profile_internship_dinh" {
  name = "ssm-ec2-profile-internship-dinh"
  role = aws_iam_role.ssm_ec2_internship_dinh.name
}


