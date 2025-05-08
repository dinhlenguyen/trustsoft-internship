########################################
# Launch Template
########################################

resource "aws_launch_template" "lt_internship_dinh" {
  name_prefix   = "lt_internship_dinh"
  image_id      = var.ami_id
  instance_type = var.instance_type

  network_interfaces {
    security_groups = [aws_security_group.web_internship_dinh.id]
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ssm_profile_internship_dinh.name
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "ec2_instance_internship_dinh"
      Environment = "Dev"
    }
  }

  user_data = base64encode(var.user_data_script)
}

########################################
# Auto Scaling Group
########################################

resource "aws_autoscaling_group" "asg_internship_dinh" {
  name               = "asg_internship_dinh"
  max_size            = 3
  min_size            = 2
  vpc_zone_identifier = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
  target_group_arns   = [aws_lb_target_group.tg_internship_dinh.arn]
  launch_template {
    id      = aws_launch_template.lt_internship_dinh.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "asg_instance_internship_dinh"
    propagate_at_launch = true
  }
}

########################################
# Auto Scaling Policies
########################################

resource "aws_autoscaling_policy" "scale_out_policy" {
  name                   = "scale_out_policy_internship_dinh"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = aws_autoscaling_group.asg_internship_dinh.name
}

resource "aws_autoscaling_policy" "scale_in_policy" {
  name                   = "scale_in_policy_internship_dinh"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = aws_autoscaling_group.asg_internship_dinh.name
}

########################################
# CloudWatch Alarm for Scaling
########################################

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpu_high_internship_dinh"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70
  alarm_actions       = [aws_autoscaling_policy.scale_out_policy.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_internship_dinh.name
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "cpu_low_internship_dinh"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 30
  alarm_actions       = [aws_autoscaling_policy.scale_in_policy.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_internship_dinh.name
  }
}
