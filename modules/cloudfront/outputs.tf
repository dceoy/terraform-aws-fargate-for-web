output "wafv2_web_acl_arn" {
  description = "ARN of the CloudFront Web ACL"
  value       = aws_wafv2_web_acl.cloudfront.arn
}

output "wafv2_web_acl_id" {
  description = "ID of the CloudFront Web ACL"
  value       = aws_wafv2_web_acl.cloudfront.id
}

output "cloudfront_default_behavior_function_arn" {
  description = "ARN of the CloudFront function used for the default behavior"
  value       = aws_cloudfront_function.default.arn
}

output "cloudfront_default_behavior_function_etag" {
  description = "ETag of the CloudFront function used for the default behavior"
  value       = aws_cloudfront_function.default.etag
}

output "cloudfront_default_behavior_function_live_stage_etag" {
  description = "Live stage ETag of the CloudFront function used for the default behavior"
  value       = aws_cloudfront_function.default.live_stage_etag
}

output "cloudfront_s3_origin_access_control_id" {
  description = "Origin access control ID for the S3 origin (null when no S3 origin is configured)"
  value       = length(aws_cloudfront_origin_access_control.s3) > 0 ? aws_cloudfront_origin_access_control.s3[0].id : null
}

output "cloudfront_s3_origin_access_control_etag" {
  description = "ETag of the S3 origin access control (null when no S3 origin is configured)"
  value       = length(aws_cloudfront_origin_access_control.s3) > 0 ? aws_cloudfront_origin_access_control.s3[0].etag : null
}

output "cloudfront_distribution_arn" {
  description = "CloudFront distribution ARN"
  value       = aws_cloudfront_distribution.cdn.arn
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.cdn.id
}

output "cloudfront_distribution_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.cdn.domain_name
}

output "cloudfront_distribution_hosted_zone_id" {
  description = "CloudFront hosted zone ID"
  value       = aws_cloudfront_distribution.cdn.hosted_zone_id
}

output "cloudfront_distribution_status" {
  description = "CloudFront distribution status"
  value       = aws_cloudfront_distribution.cdn.status
}

output "cloudfront_distribution_etag" {
  description = "ETag of the CloudFront distribution"
  value       = aws_cloudfront_distribution.cdn.etag
}

output "cloudfront_monitoring_subscription_id" {
  description = "ID of the CloudFront monitoring subscription"
  value       = aws_cloudfront_monitoring_subscription.cdn.id
}
