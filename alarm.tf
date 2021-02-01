#*********** ALARMS ************

resource "aws_cloudwatch_metric_alarm" "health" {
  alarm_name                = "web-health-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "StatusCheckFailed"
  namespace                 = "AWS/ApplicationELB"                          
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "1"
  alarm_description         = "This metric monitors alb health status"
  alarm_actions             = [ "${aws_sns_topic.alarm.arn}" ]

  dimensions = {
    InstanceId = aws_alb.web_alb.id              
  }
}
