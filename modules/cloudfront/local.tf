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
  cloudfront_disabled_cache_policy_id  = data.aws_cloudfront_cache_policy.disabled.id
  cloudfront_optimized_cache_policy_id = data.aws_cloudfront_cache_policy.optimized.id
  cloudfront_origin_request_policy_id  = data.aws_cloudfront_origin_request_policy.all.id
}
