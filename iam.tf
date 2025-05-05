########################################
# IAM Role for EC2 Systems Manager (SSM)
########################################

resource "aws_iam_role" "ssm_s3_internship_dinh" {
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
# Attach CloudWatch Agent Server Policy
########################################

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_attach" {
  role       = aws_iam_role.ssm_s3_internship_dinh.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

########################################
# IAM Instance Profile
# Needed to attach IAM Role to EC2 Instances
########################################

resource "aws_iam_instance_profile" "ssm_profile_internship_dinh" {
  name = "ssm-s3-profile-internship-dinh"
  role = aws_iam_role.ssm_s3_internship_dinh.name
}

########################################
# SSM Document: CloudWatch Agent Config
########################################
data "aws_ssm_document" "cwagent_document" {
  name = "AmazonCloudWatch-ManageAgent"
}

########################################
# SSM Parameter
########################################
resource "aws_ssm_parameter" "cwagent_config" {
  name        = "AmazonCloudWatch-linux"
  type        = "String"
  description = "CloudWatch Agent configuration for EC2 instances"
  overwrite   = true
  tier        = "Standard"
  value       = file("${path.module}/cwagent-config.json")

  tags = {
    Name = "cwagent-config"
  }
}
########################################
# SSM Association to install the agent
########################################
resource "aws_ssm_association" "install_cwagent_a" {
  name = "AWS-ConfigureAWSPackage"

  targets {
    key    = "InstanceIds"
    values = [aws_instance.web_a_internship_dinh.id]
  }

  parameters = {
    action = "Install"
    name   = "AmazonCloudWatchAgent"
  }

  depends_on = [aws_instance.web_a_internship_dinh]
}

resource "aws_ssm_association" "install_cwagent_b" {
  name = "AWS-ConfigureAWSPackage"

  targets {
    key    = "InstanceIds"
    values = [aws_instance.web_b_internship_dinh.id]
  }

  parameters = {
    action = "Install"
    name   = "AmazonCloudWatchAgent"
  }

  depends_on = [aws_instance.web_b_internship_dinh]
}


########################################
# SSM Association for EC2 Instance A
########################################

resource "aws_ssm_association" "cwagent_association_a" {
  name             = data.aws_ssm_document.cwagent_document.name
  association_name = "cwagent-ec2a-association"

  targets {
    key    = "InstanceIds"
    values = [aws_instance.web_a_internship_dinh.id]
  }

  parameters = {
    action                        = "configure"
    mode                          = "ec2"
    optionalConfigurationSource   = "ssm"
    optionalConfigurationLocation = "AmazonCloudWatch-linux"
    optionalRestart               = "yes"
  }

  depends_on = [
    aws_iam_role_policy_attachment.cloudwatch_agent_attach,
    aws_ssm_parameter.cwagent_config,
    aws_instance.web_a_internship_dinh
  ]
}


########################################
# SSM Association for EC2 Instance B
########################################

resource "aws_ssm_association" "cwagent_association_b" {
  name             = data.aws_ssm_document.cwagent_document.name
  association_name = "cwagent-ec2b-association"

  targets {
    key    = "InstanceIds"
    values = [aws_instance.web_b_internship_dinh.id]
  }

  parameters = {
    action                        = "configure"
    mode                          = "ec2"
    optionalConfigurationSource   = "ssm"
    optionalConfigurationLocation = "AmazonCloudWatch-linux"
    optionalRestart               = "yes"
  }

  depends_on = [
    aws_iam_role_policy_attachment.cloudwatch_agent_attach,
    aws_ssm_parameter.cwagent_config,
    aws_instance.web_b_internship_dinh
  ]
}

