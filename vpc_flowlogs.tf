resource "aws_flow_log" "vpc_flow_logs" {
  iam_role_arn         = aws_iam_role.flow_log_role.arn
  log_destination      = aws_cloudwatch_log_group.log_group.arn
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.vpc_internship_dinh.id
  log_destination_type = "cloud-watch-logs"

  tags = {
    Name = "vpc-flow-logs-internship-dinh"
  }
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "vpc_log_group_internship_dinh"
  retention_in_days = 3
}

resource "aws_iam_role" "flow_log_role" {
  name               = "flow-log-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "flow_log_policy" {
  name        = "flow-log-policy"
  description = "Policy for VPC flow logs"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VPCFlowLogsAccess",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "flow_log_policy_attachment" {
  role       = aws_iam_role.flow_log_role.name
  policy_arn = aws_iam_policy.flow_log_policy.arn
}