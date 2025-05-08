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
# SSM install document
########################################
resource "aws_ssm_document" "cw_agent_install" {
  name            = "Linux-InstallCloudWatchAgent-internship-dinh"
  document_type   = "Command"
  document_format = "YAML"

  content = <<DOC
schemaVersion: '2.2'
description: 'Install and configure CloudWatch agent'
parameters:
  action:
    type: String
    description: "(Required) Specify whether or not to install or uninstall CloudWatch agent"
    allowedValues:
      - Install
    default: Install
  configurationLocation:
    type: String
    description: "SSM Parameter Store location containing the CloudWatch agent configuration"
    default: "${aws_ssm_parameter.cw_agent_config.name}"
mainSteps:
  - action: aws:configurePackage
    name: installCWAgent
    inputs:
      name: AmazonCloudWatchAgent
      action: "{{ action }}"
  - action: aws:runShellScript
    name: configureAgent
    inputs:
      runCommand:
        - |
            sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c ssm:{{ configurationLocation }} -s
DOC
}

########################################
# SSM update document
########################################
resource "aws_ssm_document" "cw_agent_update" {
  name            = "Linux-UpdateCloudWatchAgent-internship-dinh"
  document_type   = "Command"
  document_format = "YAML"

  content = <<DOC
schemaVersion: '2.2'
description: 'Update CloudWatch agent to latest version'
mainSteps:
  - action: aws:configurePackage
    name: updateCWAgent
    inputs:
      name: AmazonCloudWatchAgent
      action: Install
DOC
}

########################################
# SSM parameter
########################################
resource "aws_ssm_parameter" "cw_agent_config" {
  name      = "Cloudwatch-agent-internship-dinh"
  type      = "String"
  overwrite = true # Optional, useful if parameter already exists
  value = jsonencode({
    agent = {
      metrics_collection_interval = 300
      run_as_user                 = "root"
    }
    metrics = {
      namespace = "Dinh"
      append_dimensions = {
        InstanceId = "$${aws:InstanceId}"
      }
      metrics_collected = {
        mem = {
          measurement                 = ["mem_used_percent"]
          metrics_collection_interval = 5
        }
        disk = {
          measurement                 = ["disk_used_percent"]
          metrics_collection_interval = 5
          resources                   = ["/"]
          ignore_file_system_types    = ["tmpfs", "devtmpfs"]
        }
      }
    }
  })
}

########################################
# SSM associations
########################################
resource "aws_ssm_association" "manage_cloudwatch_agent_a" {
  name = aws_ssm_document.cw_agent_install.name

  targets {
    key    = "InstanceIds"
    values = [aws_instance.web_a_internship_dinh.id]
  }

  parameters = {
    action                = "Install"
    configurationLocation = aws_ssm_parameter.cw_agent_config.name
  }

  depends_on = [
    aws_ssm_document.cw_agent_install,
    aws_instance.web_a_internship_dinh
  ]
}

resource "aws_ssm_association" "manage_cloudwatch_agent_b" {
  name = aws_ssm_document.cw_agent_install.name

  targets {
    key    = "InstanceIds"
    values = [aws_instance.web_b_internship_dinh.id]
  }

  parameters = {
    action                = "Install"
    configurationLocation = aws_ssm_parameter.cw_agent_config.name
  }

  depends_on = [
    aws_ssm_document.cw_agent_install,
    aws_instance.web_b_internship_dinh
  ]
}

resource "aws_ssm_association" "update_cloudwatch_agent_a" {
  name = aws_ssm_document.cw_agent_update.name

  targets {
    key    = "InstanceIds"
    values = [aws_instance.web_a_internship_dinh.id]
  }

  depends_on = [
    aws_ssm_document.cw_agent_update,
    aws_instance.web_a_internship_dinh,
    aws_ssm_association.manage_cloudwatch_agent_a
  ]
}

resource "aws_ssm_association" "update_cloudwatch_agent_b" {
  name = aws_ssm_document.cw_agent_update.name

  targets {
    key    = "InstanceIds"
    values = [aws_instance.web_b_internship_dinh.id]
  }

  depends_on = [
    aws_ssm_document.cw_agent_update,
    aws_instance.web_b_internship_dinh,
    aws_ssm_association.manage_cloudwatch_agent_b
  ]
}
