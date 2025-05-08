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

resource "aws_cloudwatch_metric_alarm" "ec2_cpu_high_internship_dinh" {
  for_each = aws_instance.web_instances

  alarm_name          = "${each.key}-cpu-high-internship-dinh"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 10

  alarm_description = "Alarm when ${each.key} CPU exceeds 10% for 4 minutes"
  dimensions = {
    InstanceId = each.value.id
  }

  treat_missing_data = "notBreaching"

  # send to SNS topic when alarm state changes
  alarm_actions = [aws_sns_topic.alarms_internship_dinh.arn]
  ok_actions    = [aws_sns_topic.alarms_internship_dinh.arn]

  tags = {
    Name = "alarm_${each.key}_cpu_internship_dinh"
  }
}