variable "system_name" {
  description = "System name"
  type        = string
}

variable "env_type" {
  description = "Environment type"
  type        = string
}

variable "alb_dns_name" {
  description = "ALB DNS name used as a CloudFront origin"
  type        = string
  default     = null
}

variable "lambda_function_url" {
  description = "Lambda function URL used as a CloudFront origin"
  type        = string
  default     = null
}

variable "create_cloudfront_lambda_origin_access_control" {
  description = "Whether to create a CloudFront Origin Access Control for the Lambda function URL"
  type        = bool
  default     = true
}

variable "s3_bucket_regional_domain_name" {
  description = "S3 bucket regional domain name used as a CloudFront origin"
  type        = string
  default     = null
}

variable "wafv2_visibility_config_cloudwatch_metrics_enabled" {
  description = "Whether to send metrics to CloudWatch for the WAFv2 Web ACL"
  type        = bool
  default     = true
}

variable "wafv2_visibility_config_sampled_requests_enabled" {
  description = "Whether to store a sampling of the web requests that match the rules in the WAFv2 Web ACL"
  type        = bool
  default     = true
}

variable "wafv2_aws_managed_rules" {
  description = "List of AWS managed rules to include in the WAFv2 Web ACL"
  type        = list(map(string))
  default = [
    {
      name            = "AWSManagedRulesCommonRuleSet"
      override_action = "none"
    },
    {
      name            = "AWSManagedRulesAmazonIpReputationList"
      override_action = "none"
    }
  ]
}

variable "cloudfront_function_runtime" {
  description = "Runtime for the CloudFront function"
  type        = string
  default     = "cloudfront-js-2.0"
  validation {
    condition     = contains(["cloudfront-js-1.0", "cloudfront-js-2.0"], var.cloudfront_function_runtime)
    error_message = "CloudFront function runtime must be cloudfront-js-1.0 or cloudfront-js-2.0"
  }
}

variable "cloudfront_function_publish" {
  description = "Whether to publish creation/change as Live CloudFront Function Version"
  type        = bool
  default     = true
}

variable "cloudfront_enabled" {
  description = "Whether to enable the CloudFront distribution"
  type        = bool
  default     = true
}

variable "cloudfront_is_ipv6_enabled" {
  description = "Whether to enable IPv6 for the CloudFront distribution"
  type        = bool
  default     = true
}

variable "cloudfront_aliases" {
  description = "Extra CNAMEs (alternate domain names) for the CloudFront distribution"
  type        = list(string)
  default     = []
}

variable "cloudfront_http_version" {
  description = "Maximum HTTP version that viewers can use to communicate with CloudFront"
  type        = string
  default     = "http2and3"
  validation {
    condition     = contains(["http1.1", "http2", "http2and3", "http3"], var.cloudfront_http_version)
    error_message = "HTTP version must be http1.1, http2, http2and3, or http3"
  }
}

variable "cloudfront_default_root_object" {
  description = "Object that CloudFront serves when the root URL is requested"
  type        = string
  default     = null
}

variable "cloudfront_cache_behavior_viewer_protocol_policy" {
  description = "Viewer protocol policy for the CloudFront distribution cache behaviors"
  type        = string
  default     = "redirect-to-https"
  validation {
    condition     = contains(["allow-all", "https-only", "redirect-to-https"], var.cloudfront_cache_behavior_viewer_protocol_policy)
    error_message = "Viewer protocol policy must be allow-all, https-only, or redirect-to-https"
  }
}

variable "cloudfront_price_class" {
  description = "Price class for the CloudFront distribution"
  type        = string
  default     = "PriceClass_All"
  validation {
    condition     = contains(["PriceClass_All", "PriceClass_200", "PriceClass_100"], var.cloudfront_price_class)
    error_message = "Price class must be PriceClass_All, PriceClass_200, or PriceClass_100"
  }
}

variable "cloudfront_retain_on_delete" {
  description = "Whether to disable the CloudFront distribution instead of deleting it on destroy"
  type        = bool
  default     = false
}

variable "cloudfront_wait_for_deployment" {
  description = "Whether to wait for the CloudFront distribution status to change from InProgress to Deployed"
  type        = bool
  default     = true
}

variable "cloudfront_staging" {
  description = "Whether the CloudFront distribution is a staging distribution"
  type        = bool
  default     = false
}

variable "cloudfront_origin_custom_headers" {
  description = "Custom headers to add to requests sent to the origin by CloudFront"
  type        = map(string)
  default     = {}
}

variable "cloudfront_origin_request_managed_policy_name" {
  description = "Managed origin request policy name for CloudFront cache behaviors"
  type        = string
  default     = "Managed-AllViewerAndCloudFrontHeaders-2022-06"
}

variable "cloudfront_ordered_cache_behavior_alb_path_pattern" {
  description = "Path pattern of the CloudFront ordered cache behavior for the ALB origin"
  type        = string
  default     = "/alb/*"
}

variable "cloudfront_ordered_cache_behavior_lambda_path_pattern" {
  description = "Path pattern of the CloudFront ordered cache behavior for the Lambda function URL origin"
  type        = string
  default     = "/lambda/*"
}

variable "cloudfront_ordered_cache_behavior_s3_path_pattern" {
  description = "Path pattern of the CloudFront ordered cache behavior for the S3 origin"
  type        = string
  default     = "/s3/*"
}

variable "cloudfront_geo_restriction_type" {
  description = "Method to restrict distribution by country for the CloudFront distribution"
  type        = string
  default     = "none"
  validation {
    condition     = contains(["none", "blacklist", "whitelist"], var.cloudfront_geo_restriction_type)
    error_message = "Geo restriction type must be none, blacklist, or whitelist"
  }
}

variable "cloudfront_geo_restriction_locations" {
  description = "ISO 3166-1-alpha-2 codes for countries to include in a blacklist or whitelist for the CloudFront distribution"
  type        = list(string)
  default     = []
}

variable "cloudfront_viewer_certificate_acm_arn" {
  description = "ARN of the AWS Certificate Manager certificate to be used for HTTPS connections between viewers and the CloudFront distribution"
  type        = string
  default     = null
}

variable "cloudfront_viewer_certificate_minimum_protocol_version" {
  description = "Minimum version of the SSL protocol to be used for HTTPS connections between viewers and the CloudFront distribution"
  type        = string
  default     = "TLSv1"
}

variable "cloudfront_realtime_metrics_subscription_status" {
  description = "CloudFront real-time log configuration subscription status"
  type        = string
  default     = "Enabled"
}

variable "route53_record_zone_id" {
  description = "Route 53 record hosted zone ID for the CloudFront distribution"
  type        = string
  default     = null
}

variable "route53_record_name" {
  description = "Route 53 record name for the CloudFront distribution"
  type        = string
  default     = ""
}

variable "route53_record_type" {
  description = "Route 53 record type for the CloudFront distribution"
  type        = string
  default     = "A"
  validation {
    condition     = var.route53_record_type == "A" || var.route53_record_type == "AAAA"
    error_message = "Route 53 record type must be A or AAAA"
  }
}

variable "route53_record_allow_overwrite" {
  description = "Whether to allow the Route 53 record to be overwritten"
  type        = bool
  default     = false
}

variable "route53_record_alias_evaluate_target_health" {
  description = "Whether to evaluate the health of the CloudFront distribution for responding to Route 53 DNS queries"
  type        = bool
  default     = true
}
