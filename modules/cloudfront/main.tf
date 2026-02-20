resource "aws_wafv2_web_acl" "cloudfront" {
  # checkov:skip=CKV_AWS_192:Managed rule groups are configurable for this ACL
  # checkov:skip=CKV2_AWS_31:WAF logging configuration is optional and managed externally
  name_prefix = "${var.system_name}-${var.env_type}-wafv2-web-acl-"
  description = "WAFv2 Web ACL with AWS managed rules"
  scope       = "CLOUDFRONT"
  region      = local.cloudfront_region
  default_action {
    allow {}
  }
  dynamic "rule" {
    for_each = { for i, g in var.wafv2_aws_managed_rule_group_names : i => g }
    content {
      name     = rule.value
      priority = rule.key
      statement {
        managed_rule_group_statement {
          name        = rule.value
          vendor_name = "AWS"
          dynamic "rule_action_override" {
            for_each = lookup(var.wafv2_aws_managed_rule_group_rule_action_override_actions, rule.value, {})
            content {
              name = rule_action_override.key
              action_to_use {
                dynamic "allow" {
                  for_each = rule_action_override.value == "allow" ? [true] : []
                  content {}
                }
                dynamic "block" {
                  for_each = rule_action_override.value == "block" ? [true] : []
                  content {}
                }
                dynamic "count" {
                  for_each = rule_action_override.value == "count" ? [true] : []
                  content {}
                }
                dynamic "captcha" {
                  for_each = rule_action_override.value == "captcha" ? [true] : []
                  content {}
                }
                dynamic "challenge" {
                  for_each = rule_action_override.value == "challenge" ? [true] : []
                  content {}
                }
              }
            }
          }
        }
      }
      override_action {
        dynamic "none" {
          for_each = lookup(var.wafv2_aws_managed_rule_group_override_action, rule.value, "none") == "none" ? [true] : []
          content {}
        }
        dynamic "count" {
          for_each = lookup(var.wafv2_aws_managed_rule_group_override_action, rule.value, "none") == "count" ? [true] : []
          content {}
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = var.wafv2_visibility_config_cloudwatch_metrics_enabled
        metric_name                = rule.value
        sampled_requests_enabled   = var.wafv2_visibility_config_sampled_requests_enabled
      }
    }
  }
  visibility_config {
    cloudwatch_metrics_enabled = var.wafv2_visibility_config_cloudwatch_metrics_enabled
    metric_name                = "${var.system_name}-${var.env_type}-wafv2-web-acl"
    sampled_requests_enabled   = var.wafv2_visibility_config_sampled_requests_enabled
  }
  tags = {
    Name       = "${var.system_name}-${var.env_type}-wafv2-web-acl"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_cloudfront_function" "block" {
  name    = "${var.system_name}-${var.env_type}-cloudfront-block-function"
  comment = "CloudFront Function to return 403 Forbidden"
  runtime = var.cloudfront_function_runtime
  publish = var.cloudfront_function_publish
  code    = <<-EOT
  function handler(event) {
    return {
      statusCode: 403,
      statusDescription: 'Forbidden',
      headers: { 'cache-control': { value: 'no-store' } }
    };
  }
  EOT
}

resource "aws_cloudfront_function" "forward" {
  name    = "${var.system_name}-${var.env_type}-cloudfront-forward-function"
  comment = "CloudFront Function to add X-Forwarded-Host header"
  runtime = var.cloudfront_function_runtime
  publish = var.cloudfront_function_publish
  code    = <<-EOT
  function handler(event) {
    var r = event.request;
    r.headers['x-forwarded-host'] = r.headers.host;
    return r;
  }
  EOT
}

resource "aws_cloudfront_origin_access_control" "lambda" {
  count                             = contains(keys(local.cloudfront_origin_ids), "lambda") && var.lambda_function_name_with_iam_authorization != null ? 1 : 0
  name                              = "${var.system_name}-${var.env_type}-lambda-cloudfront-oac"
  description                       = "CloudFront Origin Access Control for Lambda"
  origin_access_control_origin_type = "lambda"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_origin_access_control" "s3" {
  count                             = contains(keys(local.cloudfront_origin_ids), "s3") ? 1 : 0
  name                              = "${var.system_name}-${var.env_type}-s3-cloudfront-oac"
  description                       = "CloudFront Origin Access Control for S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# trivy:ignore:AVD-AWS-0010
resource "aws_cloudfront_distribution" "cdn" {
  # checkov:skip=CKV_AWS_86:Logging is optional and managed via log delivery resources
  # checkov:skip=CKV_AWS_174:TLS minimum protocol version is configurable via variables
  # checkov:skip=CKV_AWS_310:Origin failover is not required for this single-origin setup
  # checkov:skip=CKV_AWS_374:Geo restriction is configurable via variables
  # checkov:skip=CKV2_AWS_47:Log4j rule is included via configurable managed rule groups
  # checkov:skip=CKV2_AWS_32:Response headers policy is not required for this setup
  aliases             = length(var.cloudfront_aliases) > 0 ? var.cloudfront_aliases : null
  comment             = "CloudFront Distribution for ${upper(join(", ", keys(local.cloudfront_origin_domain_names)))}"
  web_acl_id          = aws_wafv2_web_acl.cloudfront.arn
  http_version        = var.cloudfront_http_version
  default_root_object = var.cloudfront_default_root_object
  enabled             = var.cloudfront_enabled
  is_ipv6_enabled     = var.cloudfront_is_ipv6_enabled
  price_class         = var.cloudfront_price_class
  retain_on_delete    = var.cloudfront_retain_on_delete
  wait_for_deployment = var.cloudfront_wait_for_deployment
  staging             = var.cloudfront_staging
  dynamic "origin" {
    for_each = { for k, v in local.cloudfront_origin_domain_names : local.cloudfront_origin_ids[k] => v if k == "alb" }
    content {
      origin_id   = origin.key
      domain_name = origin.value
      custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
      dynamic "custom_header" {
        for_each = var.cloudfront_origin_custom_headers
        content {
          name  = custom_header.key
          value = custom_header.value
        }
      }
    }
  }
  dynamic "origin" {
    for_each = { for k, v in local.cloudfront_origin_domain_names : local.cloudfront_origin_ids[k] => v if k == "lambda" }
    content {
      origin_id                = origin.key
      domain_name              = origin.value
      origin_access_control_id = length(aws_cloudfront_origin_access_control.lambda) > 0 ? aws_cloudfront_origin_access_control.lambda[0].id : null
      custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
      dynamic "custom_header" {
        for_each = var.cloudfront_origin_custom_headers
        content {
          name  = custom_header.key
          value = custom_header.value
        }
      }
    }
  }
  dynamic "origin" {
    for_each = { for k, v in local.cloudfront_origin_domain_names : local.cloudfront_origin_ids[k] => v if k == "s3" }
    content {
      origin_id                = origin.key
      domain_name              = origin.value
      origin_access_control_id = aws_cloudfront_origin_access_control.s3[0].id
    }
  }
  default_cache_behavior {
    target_origin_id         = local.cloudfront_origin_ids[local.cloudfront_default_cache_behavior_key]
    allowed_methods          = local.cloudfront_cache_behavior_allowed_methods[local.cloudfront_default_cache_behavior_key]
    cached_methods           = local.cloudfront_cache_behavior_cached_methods[local.cloudfront_default_cache_behavior_key]
    viewer_protocol_policy   = var.cloudfront_cache_behavior_viewer_protocol_policy
    cache_policy_id          = local.cloudfront_cache_behavior_cache_policy_ids[local.cloudfront_default_cache_behavior_key]
    origin_request_policy_id = local.cloudfront_cache_behavior_origin_request_policy_ids[local.cloudfront_default_cache_behavior_key]
    function_association {
      event_type   = "viewer-request"
      function_arn = local.cloudfront_default_cache_behavior_enabled ? aws_cloudfront_function.forward.arn : aws_cloudfront_function.block.arn
    }
  }
  dynamic "ordered_cache_behavior" {
    for_each = local.cloudfront_ordered_cache_behavior_path_patterns
    content {
      path_pattern             = ordered_cache_behavior.value
      target_origin_id         = local.cloudfront_origin_ids[ordered_cache_behavior.key]
      allowed_methods          = local.cloudfront_cache_behavior_allowed_methods[ordered_cache_behavior.key]
      cached_methods           = local.cloudfront_cache_behavior_cached_methods[ordered_cache_behavior.key]
      viewer_protocol_policy   = var.cloudfront_cache_behavior_viewer_protocol_policy
      cache_policy_id          = local.cloudfront_cache_behavior_cache_policy_ids[ordered_cache_behavior.key]
      origin_request_policy_id = local.cloudfront_cache_behavior_origin_request_policy_ids[ordered_cache_behavior.key]
      dynamic "function_association" {
        for_each = ordered_cache_behavior.key != "s3" ? [true] : []
        content {
          event_type   = "viewer-request"
          function_arn = aws_cloudfront_function.forward.arn
        }
      }
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = var.cloudfront_geo_restriction_type
      locations        = var.cloudfront_geo_restriction_locations
    }
  }
  viewer_certificate {
    acm_certificate_arn            = var.cloudfront_viewer_certificate_acm_arn
    cloudfront_default_certificate = var.cloudfront_viewer_certificate_acm_arn == null ? true : false
    minimum_protocol_version       = var.cloudfront_viewer_certificate_minimum_protocol_version
    ssl_support_method             = var.cloudfront_viewer_certificate_acm_arn == null ? null : "sni-only"
  }
  tags = {
    Name       = "${var.system_name}-${var.env_type}-cloudfront-distribution"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_cloudfront_monitoring_subscription" "cdn" {
  distribution_id = aws_cloudfront_distribution.cdn.id
  monitoring_subscription {
    realtime_metrics_subscription_config {
      realtime_metrics_subscription_status = var.cloudfront_realtime_metrics_subscription_status
    }
  }
}

resource "aws_cloudwatch_log_delivery_destination" "cloudfront" {
  count         = var.cloudfront_log_delivery_destination_resource_arn != null ? 1 : 0
  name          = "${var.system_name}-${var.env_type}-cloudfront-log-delivery-destination"
  region        = local.cloudfront_region
  output_format = var.cloudfront_log_delivery_destination_output_format
  delivery_destination_configuration {
    destination_resource_arn = var.cloudfront_log_delivery_destination_resource_arn
  }
  tags = {
    Name       = "${var.system_name}-${var.env_type}-cloudfront-log-delivery-destination"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_cloudwatch_log_delivery_source" "cloudfront" {
  count        = length(aws_cloudwatch_log_delivery_destination.cloudfront) > 0 ? 1 : 0
  name         = "${var.system_name}-${var.env_type}-cloudfront-log-delivery-source"
  region       = local.cloudfront_region
  log_type     = "ACCESS_LOGS"
  resource_arn = aws_cloudfront_distribution.cdn.arn
  tags = {
    Name       = "${var.system_name}-${var.env_type}-cloudfront-log-delivery-source"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_cloudwatch_log_delivery" "cloudfront" {
  count                    = length(aws_cloudwatch_log_delivery_destination.cloudfront) > 0 ? 1 : 0
  region                   = local.cloudfront_region
  delivery_source_name     = aws_cloudwatch_log_delivery_source.cloudfront[0].name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.cloudfront[0].arn
  record_fields            = var.cloudfront_log_delivery_record_fields
  dynamic "s3_delivery_configuration" {
    for_each = var.cloudfront_log_delivery_s3_enable_hive_compatible_path != null || var.cloudfront_log_delivery_s3_suffix_path != null ? [true] : []
    content {
      enable_hive_compatible_path = var.cloudfront_log_delivery_s3_enable_hive_compatible_path
      suffix_path                 = var.cloudfront_log_delivery_s3_suffix_path
    }
  }
  tags = {
    Name       = "${var.system_name}-${var.env_type}-cloudfront-log-delivery"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_lambda_permission" "cloudfront" {
  for_each               = toset(length(aws_cloudfront_origin_access_control.lambda) > 0 ? ["InvokeFunctionUrl", "InvokeFunction"] : [])
  statement_id_prefix    = "${aws_cloudfront_distribution.cdn.id}-"
  action                 = "lambda:${each.key}"
  function_name          = var.lambda_function_name_with_iam_authorization
  principal              = "cloudfront.amazonaws.com"
  source_arn             = aws_cloudfront_distribution.cdn.arn
  function_url_auth_type = "AWS_IAM"
}

resource "aws_route53_record" "cloudfront" {
  count           = var.route53_record_zone_id != null ? 1 : 0
  zone_id         = var.route53_record_zone_id
  name            = var.route53_record_name
  type            = var.route53_record_type
  allow_overwrite = var.route53_record_allow_overwrite
  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = var.route53_record_alias_evaluate_target_health
  }
}
