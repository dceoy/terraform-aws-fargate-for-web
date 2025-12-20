include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "alb" {
  config_path = "../alb"
  mock_outputs = {
    lb_dns_name = "internal-lb-12345678.us-east-1.elb.amazonaws.com"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "acm" {
  config_path = "../acm"
  mock_outputs = {
    acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

inputs = {
  alb_dns_name                          = dependency.alb.outputs.lb_dns_name
  cloudfront_viewer_certificate_acm_arn = dependency.acm.outputs.acm_certificate_arn
}

terraform {
  source = "${get_repo_root()}/modules/cloudfront"
}
