data "aws_cloudfront_cache_policy" "disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_cache_policy" "optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_origin_request_policy" "all" {
  name = "Managed-AllViewerExceptHostHeader"
}

locals {
  cloudfront_cache_policy_ids = {
    alb    = data.aws_cloudfront_cache_policy.disabled.id
    lambda = data.aws_cloudfront_cache_policy.disabled.id
    s3     = data.aws_cloudfront_cache_policy.optimized.id
  }
  cloudfront_origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all.id
  cloudfront_origin_domain_names = {
    alb    = var.alb_dns_name
    lambda = var.lambda_function_url != null ? trimprefix(var.lambda_function_url, "https://") : null
    s3     = var.s3_bucket_regional_domain_name
  }
  cloudfront_origin_ids = {
    for k, v in local.cloudfront_origin_domain_names : k => "${var.system_name}-${var.env_type}-cloudfront-${k}-origin"
  }
  cloudfront_cache_behavior_path_patterns = {
    alb    = local.cloudfront_origin_domain_names["alb"] != null ? var.cloudfront_ordered_cache_behavior_alb_path_pattern : null
    lambda = local.cloudfront_origin_domain_names["lambda"] != null ? var.cloudfront_ordered_cache_behavior_lambda_path_pattern : null
    s3     = local.cloudfront_origin_domain_names["s3"] != null ? var.cloudfront_ordered_cache_behavior_s3_path_pattern : null
  }
  cloudfront_default_cache_behavior_target_origin_id = one(
    concat(
      [for k, v in local.cloudfront_cache_behavior_path_patterns : local.cloudfront_origin_ids[k] if v == "/*"],
      values(local.cloudfront_origin_ids)
    )
  )
}
