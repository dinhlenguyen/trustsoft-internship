resource "aws_sns_topic" "ec2_status_topic" {
  name = "ec2-status-check-alerts-internship-dinh"
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.ec2_status_topic.arn
  protocol  = "email"
  endpoint  = "lend03@vse.cz"
}

resource "aws_cloudwatch_metric_alarm" "ec2_a_status_check_alarm" {
  alarm_name          = "EC2-A-Status-Check-Failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "Alert if EC2 status check fails"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.ec2_status_topic.arn]

  dimensions = {
    InstanceId = aws_instance.web_a_internship_dinh.id
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_b_status_check_alarm" {
  alarm_name          = "EC2-B-Status-Check-Failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "Alert if EC2 status check fails"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.ec2_status_topic.arn]

  dimensions = {
    InstanceId = aws_instance.web_b_internship_dinh.id
  }
}
