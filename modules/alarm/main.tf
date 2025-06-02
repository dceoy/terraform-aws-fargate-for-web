resource "aws_sns_topic" "alarm" {
  name              = "${var.system_name}-${var.env_type}-alarm-sns-topic"
  display_name      = "${var.system_name}-${var.env_type}-alarm-sns-topic"
  kms_master_key_id = var.kms_key_arn
  tags = {
    SystemName = var.system_name
    EnvType    = var.env_type
    Name       = "${var.system_name}-${var.env_type}-alarm-sns-topic"
  }
}

resource "aws_sns_topic_policy" "alarm" {
  arn = aws_sns_topic.alarm.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "${aws_sns_topic.alarm.name}-policy"
    Statement = [
      {
        Sid    = "CloudWatchPublishSNSMessages"
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action   = ["sns:Publish"]
        Resource = [aws_sns_topic.alarm.arn]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = local.account_id
          }
        }
      },
      {
        Sid    = "EventsPublishSNSMessages"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = ["sns:Publish"]
        Resource = [aws_sns_topic.alarm.arn]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = local.account_id
          }
        }
      }
    ]
  })
}

resource "aws_cloudwatch_log_metric_filter" "error" {
  for_each       = { for k, v in var.cloudwatch_log_metric_filter_log_groups : k => v if v != null && v != "" }
  name           = "${var.system_name}-${var.env_type}-cloudwatch-log-metric-filter-${each.key}-error"
  log_group_name = each.value
  pattern        = var.cloudwatch_log_metric_filter_error_pattern
  metric_transformation {
    name          = "${var.system_name}-${var.env_type}-cloudwatch-log-metric-filter-${each.key}-error-count"
    namespace     = "/${var.system_name}/${var.env_type}/logs"
    value         = 1
    default_value = 0
    unit          = "Count"
  }
}

resource "aws_cloudwatch_metric_alarm" "error" {
  for_each            = aws_cloudwatch_log_metric_filter.error
  alarm_name          = "${var.system_name}-${var.env_type}-cloudwatch-metric-alarm-${each.key}-error"
  alarm_description   = "CloudWatch metric alarm for error logs in ${each.value.log_group_name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = each.value.metric_transformation[0].name
  namespace           = each.value.metric_transformation[0].namespace
  period              = var.cloudwatch_metric_alarm_period
  statistic           = "Sum"
  threshold           = 1
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.alarm.arn]
  datapoints_to_alarm = 1
  ok_actions          = []
  unit                = "Count"
  treat_missing_data  = "notBreaching"
  tags = {
    SystemName = var.system_name
    EnvType    = var.env_type
    Name       = "${var.system_name}-${var.env_type}-error-logs-alarm"
  }
}

resource "aws_cloudwatch_event_rule" "health" {
  count       = length(var.cloudwatch_event_rule_health_services) > 0 ? 1 : 0
  name        = "${var.system_name}-${var.env_type}-cloudwatch-event-rule-health"
  description = "AWS Health event"
  state       = "ENABLED"
  event_pattern = jsonencode({
    detail = {
      service           = var.cloudwatch_event_rule_health_services
      eventTypeCategory = var.cloudwatch_event_rule_health_event_type_categories
    }
    detail-type = ["AWS Health Event"]
    source      = ["aws.health"]
  })
  tags = {
    SystemName = var.system_name
    EnvType    = var.env_type
    Name       = "${var.system_name}-${var.env_type}-cloudwatch-event-rule-health"
  }
}

resource "aws_cloudwatch_event_target" "health" {
  count     = length(aws_cloudwatch_event_rule.health) > 0 ? 1 : 0
  target_id = "${var.system_name}-${var.env_type}-health-event-target"
  rule      = aws_cloudwatch_event_rule.health[0].name
  arn       = aws_sns_topic.alarm.arn
}
