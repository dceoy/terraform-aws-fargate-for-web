resource "aws_wafv2_web_acl" "cloudfront" {
  name_prefix = "${var.system_name}-${var.env_type}-wafv2-web-acl-"
  description = "WAFv2 Web ACL with AWS managed rules"
  scope       = "CLOUDFRONT"
  default_action {
    allow {}
  }
  dynamic "rule" {
    for_each = { for i, r in var.wafv2_aws_managed_rules : i => r }
    content {
      name     = rule.value.name
      priority = rule.key
      statement {
        managed_rule_group_statement {
          name        = rule.value.name
          vendor_name = "AWS"
        }
      }
      override_action {
        dynamic "none" {
          for_each = rule.value.override_action == "none" ? [true] : []
          content {}
        }
        dynamic "count" {
          for_each = rule.value.override_action == "count" ? [true] : []
          content {}
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = var.wafv2_visibility_config_cloudwatch_metrics_enabled
        metric_name                = rule.value.name
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

resource "aws_cloudfront_function" "default" {
  name    = "${var.system_name}-${var.env_type}-cloudfront-default-behavior-function"
  comment = "CloudFront Function to return 403 Forbidden for default behavior"
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

resource "aws_cloudfront_origin_access_control" "lambda" {
  count                             = var.lambda_function_url != null && var.lambda_function_url_uses_iam_authentication ? 1 : 0
  name                              = "${var.system_name}-${var.env_type}-lambda-cloudfront-oac"
  description                       = "CloudFront Origin Access Control for Lambda"
  origin_access_control_origin_type = "lambda"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_origin_access_control" "s3" {
  count                             = var.s3_bucket_regional_domain_name != null ? 1 : 0
  name                              = "${var.system_name}-${var.env_type}-s3-cloudfront-oac"
  description                       = "CloudFront Origin Access Control for S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "cdn" {
  aliases             = length(var.cloudfront_aliases) > 0 ? var.cloudfront_aliases : null
  comment             = "CloudFront Distribution for ALB"
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
    for_each = var.alb_dns_name != null ? [true] : []
    content {
      origin_id   = "alb-origin"
      domain_name = var.alb_dns_name
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
    for_each = var.lambda_function_url != null ? [true] : []
    content {
      origin_id                = "lambda-origin"
      domain_name              = replace(var.lambda_function_url, "https://", "")
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
    for_each = length(aws_cloudfront_origin_access_control.s3) > 0 ? [true] : []
    content {
      origin_id                = "s3-origin"
      domain_name              = var.s3_bucket_regional_domain_name
      origin_access_control_id = aws_cloudfront_origin_access_control.s3[0].id
    }
  }
  default_cache_behavior {
    target_origin_id       = var.alb_dns_name != null ? "alb-origin" : (var.lambda_function_url != null ? "lambda-origin" : "s3-origin")
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = var.cloudfront_cache_behavior_viewer_protocol_policy
    cache_policy_id        = local.cloudfront_disabled_cache_policy_id
    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.default.arn
    }
  }
  dynamic "ordered_cache_behavior" {
    for_each = var.alb_dns_name != null ? [true] : []
    content {
      path_pattern             = var.cloudfront_ordered_cache_behavior_alb_path_pattern
      target_origin_id         = "alb-origin"
      allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods           = ["GET", "HEAD"]
      viewer_protocol_policy   = var.cloudfront_cache_behavior_viewer_protocol_policy
      cache_policy_id          = local.cloudfront_disabled_cache_policy_id
      origin_request_policy_id = local.cloudfront_origin_request_policy_id
    }
  }
  dynamic "ordered_cache_behavior" {
    for_each = var.lambda_function_url != null ? [true] : []
    content {
      path_pattern           = var.cloudfront_ordered_cache_behavior_lambda_path_pattern
      target_origin_id       = "lambda-origin"
      allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods         = ["GET", "HEAD"]
      viewer_protocol_policy = var.cloudfront_cache_behavior_viewer_protocol_policy
      cache_policy_id        = local.cloudfront_disabled_cache_policy_id
    }
  }
  dynamic "ordered_cache_behavior" {
    for_each = length(aws_cloudfront_origin_access_control.s3) > 0 ? [true] : []
    content {
      path_pattern           = var.cloudfront_ordered_cache_behavior_s3_path_pattern
      target_origin_id       = "s3-origin"
      allowed_methods        = ["GET", "HEAD", "OPTIONS"]
      cached_methods         = ["GET", "HEAD"]
      viewer_protocol_policy = var.cloudfront_cache_behavior_viewer_protocol_policy
      cache_policy_id        = local.cloudfront_optimized_cache_policy_id
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
