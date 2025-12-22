resource "aws_wafv2_web_acl" "cloudfront" {
  name_prefix = "${var.system_name}-${var.env_type}-wafv2-web-acl-"
  description = "WAFv2 Web ACL with AWS managed rules"
  scope       = "CLOUDFRONT"
  region      = "us-east-1"
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
  count                             = local.cloudfront_origin_domain_names["lambda"] != null && var.create_cloudfront_lambda_origin_access_control ? 1 : 0
  name                              = "${var.system_name}-${var.env_type}-lambda-cloudfront-oac"
  description                       = "CloudFront Origin Access Control for Lambda"
  origin_access_control_origin_type = "lambda"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_origin_access_control" "s3" {
  count                             = local.cloudfront_origin_domain_names["s3"] != null ? 1 : 0
  name                              = "${var.system_name}-${var.env_type}-s3-cloudfront-oac"
  description                       = "CloudFront Origin Access Control for S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# trivy:ignore:AVD-AWS-0010
resource "aws_cloudfront_distribution" "cdn" {
  aliases             = length(var.cloudfront_aliases) > 0 ? var.cloudfront_aliases : null
  comment             = "CloudFront Distribution for ${upper(join(", ", [for k, v in local.cloudfront_origin_domain_names : k if v != null]))}"
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
    for_each = local.cloudfront_origin_domain_names["alb"] != null ? [true] : []
    content {
      origin_id   = local.cloudfront_origin_ids["alb"]
      domain_name = local.cloudfront_origin_domain_names["alb"]
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
    for_each = local.cloudfront_origin_domain_names["lambda"] != null ? [true] : []
    content {
      origin_id                = local.cloudfront_origin_ids["lambda"]
      domain_name              = local.cloudfront_origin_domain_names["lambda"]
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
    for_each = local.cloudfront_origin_domain_names["s3"] != null ? [true] : []
    content {
      origin_id                = local.cloudfront_origin_ids["s3"]
      domain_name              = local.cloudfront_origin_domain_names["s3"]
      origin_access_control_id = aws_cloudfront_origin_access_control.s3[0].id
    }
  }
  default_cache_behavior {
    target_origin_id       = local.cloudfront_default_cache_behavior_target_origin_id
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = var.cloudfront_cache_behavior_viewer_protocol_policy
    cache_policy_id        = [for k, v in local.cloudfront_cache_policy_ids : v if local.cloudfront_origin_ids[k] == local.cloudfront_default_cache_behavior_target_origin_id][0]
    dynamic "function_association" {
      for_each = length([for v in values(local.cloudfront_cache_behavior_path_patterns) : v if v == "/*"]) == 0 ? [true] : []
      content {
        event_type   = "viewer-request"
        function_arn = aws_cloudfront_function.default.arn
      }
    }
  }
  dynamic "ordered_cache_behavior" {
    for_each = local.cloudfront_cache_behavior_path_patterns["alb"] != null && local.cloudfront_cache_behavior_path_patterns["alb"] != "/*" ? [true] : []
    content {
      path_pattern             = local.cloudfront_cache_behavior_path_patterns["alb"]
      target_origin_id         = local.cloudfront_origin_ids["alb"]
      allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods           = ["GET", "HEAD"]
      viewer_protocol_policy   = var.cloudfront_cache_behavior_viewer_protocol_policy
      cache_policy_id          = local.cloudfront_cache_policy_ids["alb"]
      origin_request_policy_id = local.cloudfront_origin_request_policy_id
    }
  }
  dynamic "ordered_cache_behavior" {
    for_each = local.cloudfront_cache_behavior_path_patterns["lambda"] != null && local.cloudfront_cache_behavior_path_patterns["lambda"] != "/*" ? [true] : []
    content {
      path_pattern             = local.cloudfront_cache_behavior_path_patterns["lambda"]
      target_origin_id         = local.cloudfront_origin_ids["lambda"]
      allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods           = ["GET", "HEAD"]
      viewer_protocol_policy   = var.cloudfront_cache_behavior_viewer_protocol_policy
      cache_policy_id          = local.cloudfront_cache_policy_ids["lambda"]
      origin_request_policy_id = local.cloudfront_origin_request_policy_id
    }
  }
  dynamic "ordered_cache_behavior" {
    for_each = local.cloudfront_cache_behavior_path_patterns["s3"] != null && local.cloudfront_cache_behavior_path_patterns["s3"] != "/*" ? [true] : []
    content {
      path_pattern           = local.cloudfront_cache_behavior_path_patterns["s3"]
      target_origin_id       = local.cloudfront_origin_ids["s3"]
      allowed_methods        = ["GET", "HEAD", "OPTIONS"]
      cached_methods         = ["GET", "HEAD"]
      viewer_protocol_policy = var.cloudfront_cache_behavior_viewer_protocol_policy
      cache_policy_id        = local.cloudfront_cache_policy_ids["s3"]
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
