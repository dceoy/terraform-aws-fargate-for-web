data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

locals {
  lb_name                   = "${var.system_name}-${var.env_type}-alb"
  lb_restrict_to_cloudfront = length(var.cloudfront_origin_custom_headers) > 0
}
