data "aws_cloudfront_cache_policy" "all" {
  for_each = toset(values(var.cloudfront_cache_behavior_cache_policy_names))
  name     = each.key
}

data "aws_cloudfront_origin_request_policy" "all" {
  for_each = toset(values(var.cloudfront_cache_behavior_origin_request_policy_names))
  name     = each.key
}

locals {
  cloudfront_cache_behavior_allowed_methods = {
    alb    = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    lambda = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    s3     = ["GET", "HEAD", "OPTIONS"]
  }
  cloudfront_cache_behavior_cached_methods = {
    alb    = ["GET", "HEAD"]
    lambda = ["GET", "HEAD"]
    s3     = ["GET", "HEAD"]
  }
  cloudfront_origin_domain_names = {
    for k, v in {
      alb    = var.alb_dns_name
      lambda = var.lambda_function_url != null ? regex("^https://([^/]+)", var.lambda_function_url)[0] : null
      s3     = var.s3_bucket_regional_domain_name
    } : k => v if v != null
  }
  cloudfront_origin_ids = {
    for k in keys(local.cloudfront_origin_domain_names) : k => "${var.system_name}-${var.env_type}-cloudfront-${k}-origin"
  }
  cloudfront_cache_behavior_cache_policy_ids = {
    for k, v in var.cloudfront_cache_behavior_cache_policy_names : k => data.aws_cloudfront_cache_policy.all[v].id
  }
  cloudfront_cache_behavior_origin_request_policy_ids = {
    for k, v in var.cloudfront_cache_behavior_origin_request_policy_names : k => data.aws_cloudfront_origin_request_policy.all[v].id
  }
  cloudfront_default_cache_behavior_enabled = contains(values(var.cloudfront_cache_behavior_path_patterns), "/*")
  cloudfront_default_cache_behavior_key     = local.cloudfront_default_cache_behavior_enabled ? one([for k, v in var.cloudfront_cache_behavior_path_patterns : k if v == "/*"]) : keys(local.cloudfront_origin_ids)[0]
  cloudfront_ordered_cache_behavior_path_patterns = {
    for k, v in var.cloudfront_cache_behavior_path_patterns : k => v if v != "/*" && lookup(local.cloudfront_origin_ids, k, null) != null
  }
}
