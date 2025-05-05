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
# CPU Utilization Alarms
########################################

resource "aws_cloudwatch_metric_alarm" "ec2_a_cpu_high_internship_dinh" {
  alarm_name          = "ec2-a-cpu-high-internship-dinh"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 90
  dimensions = {
    InstanceId = aws_instance.web_a_internship_dinh.id
  }
  treat_missing_data = "notBreaching"
  alarm_description  = "Alarm when EC2-A CPU exceeds 90% for 4 minutes"
  alarm_actions      = [aws_sns_topic.alarms_internship_dinh.arn]
  ok_actions         = [aws_sns_topic.alarms_internship_dinh.arn]

  tags = {
    Name = "alarm_ec2_a_cpu_internship_dinh"
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_b_cpu_high_internship_dinh" {
  alarm_name          = "ec2-b-cpu-high-internship-dinh"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 90
  dimensions = {
    InstanceId = aws_instance.web_b_internship_dinh.id
  }
  treat_missing_data = "notBreaching"
  alarm_description  = "Alarm when EC2-B CPU exceeds 90% for 4 minutes"
  alarm_actions      = [aws_sns_topic.alarms_internship_dinh.arn]
  ok_actions         = [aws_sns_topic.alarms_internship_dinh.arn]

  tags = {
    Name = "alarm_ec2_b_cpu_internship_dinh"
  }
}

########################################
# Memory Usage Alarms (Custom Metrics)
########################################

resource "aws_cloudwatch_metric_alarm" "ec2_a_memory_high" {
  alarm_name          = "ec2-a-memory-high-internship-dinh"
  namespace           = "CWAgent"
  metric_name         = "mem_used_percent"
  dimensions          = { InstanceId = aws_instance.web_a_internship_dinh.id }
  statistic           = "Average"
  period              = 120
  evaluation_periods  = 2
  threshold           = 90
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_description   = "Memory usage > 90% on EC2 A"
  alarm_actions       = [aws_sns_topic.alarms_internship_dinh.arn]
  ok_actions          = [aws_sns_topic.alarms_internship_dinh.arn]
}

resource "aws_cloudwatch_metric_alarm" "ec2_b_memory_high" {
  alarm_name          = "ec2-b-memory-high-internship-dinh"
  namespace           = "CWAgent"
  metric_name         = "mem_used_percent"
  dimensions          = { InstanceId = aws_instance.web_b_internship_dinh.id }
  statistic           = "Average"
  period              = 120
  evaluation_periods  = 2
  threshold           = 90
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_description   = "Memory usage > 90% on EC2 B"
  alarm_actions       = [aws_sns_topic.alarms_internship_dinh.arn]
  ok_actions          = [aws_sns_topic.alarms_internship_dinh.arn]
}

########################################
# Disk Usage Alarms (Custom Metrics)
########################################

resource "aws_cloudwatch_metric_alarm" "ec2_a_disk_high" {
  alarm_name          = "ec2-a-disk-high-internship-dinh"
  namespace           = "CWAgent"
  metric_name         = "disk_used_percent"
  dimensions          = {
    InstanceId = aws_instance.web_a_internship_dinh.id,
    path       = "/",
    fstype     = "xfs"
  }
  statistic           = "Average"
  period              = 120
  evaluation_periods  = 2
  threshold           = 90
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_description   = "Disk usage > 90% on EC2 A"
  alarm_actions       = [aws_sns_topic.alarms_internship_dinh.arn]
  ok_actions          = [aws_sns_topic.alarms_internship_dinh.arn]
}

resource "aws_cloudwatch_metric_alarm" "ec2_b_disk_high" {
  alarm_name          = "ec2-b-disk-high-internship-dinh"
  namespace           = "CWAgent"
  metric_name         = "disk_used_percent"
  dimensions          = {
    InstanceId = aws_instance.web_b_internship_dinh.id,
    path       = "/",
    fstype     = "xfs"
  }
  statistic           = "Average"
  period              = 120
  evaluation_periods  = 2
  threshold           = 90
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_description   = "Disk usage > 90% on EC2 B"
  alarm_actions       = [aws_sns_topic.alarms_internship_dinh.arn]
  ok_actions          = [aws_sns_topic.alarms_internship_dinh.arn]
}
