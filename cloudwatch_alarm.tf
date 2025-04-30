resource "aws_cloudwatch_metric_alarm" "ec2_a_cpu_high_internship_dinh" {
  alarm_name          = "ec2-a-cpu-high-internship-dinh"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 10

  alarm_description   = "Alarm when EC2-A CPU exceeds 10% for 4 minutes"
  dimensions = {
    InstanceId = aws_instance.web_a_internship_dinh.id
  }

  treat_missing_data = "notBreaching"
  actions_enabled    = false

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
  threshold           = 10

  alarm_description   = "Alarm when EC2-B CPU exceeds 10% for 4 minutes"
  dimensions = {
    InstanceId = aws_instance.web_b_internship_dinh.id
  }

  treat_missing_data = "notBreaching"
  actions_enabled    = false

  tags = {
    Name = "alarm_ec2_b_cpu_internship_dinh"
  }
}
