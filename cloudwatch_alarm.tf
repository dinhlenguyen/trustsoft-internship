########################################
# SNS Topic & Subscription for Alarms
########################################

resource "aws_sns_topic" "alarms_internship_dinh" {
  name = "alarms-internship-dinh"
}

resource "aws_sns_topic_subscription" "email_internship_dinh" {
  for_each  = toset(var.notification_emails)
  topic_arn = aws_sns_topic.alarms_internship_dinh.arn
  protocol  = "email"
  endpoint  = each.value
}

########################################
# CPU Utilization Alarms with SNS Actions
########################################

resource "aws_cloudwatch_metric_alarm" "ec2_a_cpu_high_internship_dinh" {
  alarm_name          = "ec2-a-cpu-high-internship-dinh"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 2

  alarm_description = "Alarm when EC2-A CPU exceeds 10% for 4 minutes"
  dimensions = {
    InstanceId = aws_instance.web_a_internship_dinh.id
  }

  treat_missing_data = "notBreaching"

  # send to SNS topic when alarm state changes
  alarm_actions = [aws_sns_topic.alarms_internship_dinh.arn]
  ok_actions    = [aws_sns_topic.alarms_internship_dinh.arn]

  tags = {
    Name = "alarm_ec2_a_cpu_internship_dinh"
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_b_cpu_high_internship_dinh" {
  alarm_name          = "ec2-b-cpu-high-internship-dinh"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 2

  alarm_description = "Alarm when EC2-B CPU exceeds 10% for 4 minutes"
  dimensions = {
    InstanceId = aws_instance.web_b_internship_dinh.id
  }

  treat_missing_data = "notBreaching"

  alarm_actions = [aws_sns_topic.alarms_internship_dinh.arn]
  ok_actions    = [aws_sns_topic.alarms_internship_dinh.arn]

  tags = {
    Name = "alarm_ec2_b_cpu_internship_dinh"
  }
}
