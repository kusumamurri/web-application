#Scale up alarm

resource "aws_autoscaling_policy" "cpu-policy-scaleup" {
  name                   = "cpu-policy-scaleup"
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}


#Cloud Watch Alarm
resource "aws_cloudwatch_metric_alarm" "high-cpu-alarm" {
  alarm_name          = "high-cpu-alarm"
  alarm_description   = "Notifies-Alert-when-cpu-utilization-exceeds-threshold-limit"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "70"
  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.web_asg.name}"
  }
  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.cpu-policy-scaleup.arn}"]
}


# scale down alarm
resource "aws_autoscaling_policy" "cpu-policy-scaledown" {
  name                   = "cpu-policy-scaledown"
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}


#Cloud Watch Alarm
resource "aws_cloudwatch_metric_alarm" "low-cpu-alarm" {
  alarm_name          = "low-cpu-alarm"
  alarm_description   = "Notifies-Alert-when-cpu-utilization-lowerthan-threshold-limit"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "30"
  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.web_asg.name}"
  }
  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.cpu-policy-scaledown.arn}"]
}

