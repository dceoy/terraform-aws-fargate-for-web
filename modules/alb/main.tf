# trivy:ignore:AVD-AWS-0104
# trivy:ignore:AVD-AWS-0107
resource "aws_security_group" "alb" {
  name        = "${var.system_name}-${var.env_type}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id
  ingress {
    description      = "Allow inbound traffic on ALB ports"
    from_port        = var.lb_security_group_ingress_from_port
    to_port          = var.lb_security_group_ingress_to_port
    protocol         = var.lb_security_group_ingress_protocol
    cidr_blocks      = var.lb_security_group_ingress_ipv4_cidr_blocks
    ipv6_cidr_blocks = var.lb_security_group_ingress_ipv6_cidr_blocks
  }
  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name       = "${var.system_name}-${var.env_type}-alb-sg"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
  lifecycle {
    create_before_destroy = true
  }
}

# trivy:ignore:AVD-AWS-0053
resource "aws_lb" "app" {
  name                                        = local.lb_name
  internal                                    = false
  load_balancer_type                          = "application"
  security_groups                             = [aws_security_group.alb.id]
  subnets                                     = var.public_subnet_ids
  drop_invalid_header_fields                  = true
  client_keep_alive                           = var.lb_client_keep_alive
  customer_owned_ipv4_pool                    = var.lb_customer_owned_ipv4_pool
  desync_mitigation_mode                      = var.lb_desync_mitigation_mode
  enable_deletion_protection                  = var.lb_enable_deletion_protection
  enable_http2                                = var.lb_enable_http2
  enable_tls_version_and_cipher_suite_headers = var.lb_enable_tls_version_and_cipher_suite_headers
  enable_waf_fail_open                        = var.lb_enable_waf_fail_open
  enable_xff_client_port                      = var.lb_enable_xff_client_port
  enable_zonal_shift                          = var.lb_enable_zonal_shift
  idle_timeout                                = var.lb_idle_timeout
  ip_address_type                             = var.lb_ip_address_type
  preserve_host_header                        = var.lb_preserve_host_header
  xff_header_processing_mode                  = var.lb_xff_header_processing_mode
  dynamic "access_logs" {
    for_each = var.lb_logs_s3_bucket_id != null ? [true] : []
    content {
      enabled = true
      bucket  = var.lb_logs_s3_bucket_id
      prefix  = "${local.lb_name}/access"
    }
  }
  dynamic "connection_logs" {
    for_each = var.lb_logs_s3_bucket_id != null ? [true] : []
    content {
      enabled = true
      bucket  = var.lb_logs_s3_bucket_id
      prefix  = "${local.lb_name}/connection"
    }
  }
  tags = {
    Name       = local.lb_name
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_lb_target_group" "app" {
  name                              = "${local.lb_name}-target-group"
  port                              = var.lb_target_group_port
  protocol                          = var.lb_target_group_protocol
  protocol_version                  = var.lb_target_group_protocol_version
  target_type                       = "ip"
  vpc_id                            = var.vpc_id
  ip_address_type                   = var.lb_target_group_ip_address_type
  deregistration_delay              = var.lb_target_group_deregistration_delay
  load_balancing_algorithm_type     = var.lb_target_group_load_balancing_algorithm_type
  load_balancing_anomaly_mitigation = var.lb_target_group_load_balancing_anomaly_mitigation
  load_balancing_cross_zone_enabled = var.lb_target_group_load_balancing_cross_zone_enabled
  preserve_client_ip                = var.lb_target_group_protocol != "HTTP" ? var.lb_target_group_preserve_client_ip : null
  slow_start                        = var.lb_target_group_slow_start
  dynamic "health_check" {
    for_each = length(var.lb_target_group_health_check) > 0 ? [true] : []
    content {
      enabled             = lookup(var.lb_target_group_health_check, "enabled", null)
      healthy_threshold   = lookup(var.lb_target_group_health_check, "healthy_threshold", null)
      interval            = lookup(var.lb_target_group_health_check, "interval", null)
      matcher             = lookup(var.lb_target_group_health_check, "matcher", null)
      path                = lookup(var.lb_target_group_health_check, "path", null)
      port                = lookup(var.lb_target_group_health_check, "port", null)
      protocol            = lookup(var.lb_target_group_health_check, "protocol", null)
      timeout             = lookup(var.lb_target_group_health_check, "timeout", null)
      unhealthy_threshold = lookup(var.lb_target_group_health_check, "unhealthy_threshold", null)
    }
  }
  dynamic "stickiness" {
    for_each = length(var.lb_target_group_stickiness) > 0 ? [true] : []
    content {
      enabled         = lookup(var.lb_target_group_stickiness, "enabled", null)
      type            = lookup(var.lb_target_group_stickiness, "type", null)
      cookie_duration = lookup(var.lb_target_group_stickiness, "cookie_duration", null)
      cookie_name     = lookup(var.lb_target_group_stickiness, "cookie_name", null)
    }
  }
  dynamic "target_group_health" {
    for_each = length(var.lb_target_group_health_dns_failover) > 0 || length(var.lb_target_group_health_unhealthy_state_routing) > 0 ? [true] : []
    content {
      dynamic "dns_failover" {
        for_each = length(var.lb_target_group_health_dns_failover) > 0 ? [true] : []
        content {
          minimum_healthy_targets_count      = lookup(var.lb_target_group_health_dns_failover, "minimum_healthy_targets_count", null)
          minimum_healthy_targets_percentage = lookup(var.lb_target_group_health_dns_failover, "minimum_healthy_targets_percentage", null)
        }
      }
      dynamic "unhealthy_state_routing" {
        for_each = length(var.lb_target_group_health_unhealthy_state_routing) > 0 ? [true] : []
        content {
          minimum_healthy_targets_count      = lookup(var.lb_target_group_health_unhealthy_state_routing, "minimum_healthy_targets_count", null)
          minimum_healthy_targets_percentage = lookup(var.lb_target_group_health_unhealthy_state_routing, "minimum_healthy_targets_percentage", null)
        }
      }
    }
  }
  tags = {
    Name       = "${local.lb_name}-target-group"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
  lifecycle {
    create_before_destroy = true
  }
}

# trivy:ignore:AVD-AWS-0054
resource "aws_lb_listener" "app" {
  load_balancer_arn                                                     = aws_lb.app.arn
  port                                                                  = var.lb_listener_port
  protocol                                                              = var.lb_listener_protocol
  ssl_policy                                                            = contains(["HTTPS", "TLS"], var.lb_listener_protocol) ? var.lb_listener_ssl_policy : null
  certificate_arn                                                       = var.lb_listener_certificate_arn
  routing_http_response_server_enabled                                  = var.lb_listener_routing_http_response_server_enabled
  routing_http_response_strict_transport_security_header_value          = var.lb_listener_routing_http_response_strict_transport_security_header_value
  routing_http_response_access_control_allow_origin_header_value        = var.lb_listener_routing_http_response_access_control_allow_origin_header_value
  routing_http_response_access_control_allow_methods_header_value       = var.lb_listener_routing_http_response_access_control_allow_methods_header_value
  routing_http_response_access_control_allow_headers_header_value       = var.lb_listener_routing_http_response_access_control_allow_headers_header_value
  routing_http_response_access_control_allow_credentials_header_value   = var.lb_listener_routing_http_response_access_control_allow_credentials_header_value
  routing_http_response_access_control_expose_headers_header_value      = var.lb_listener_routing_http_response_access_control_expose_headers_header_value
  routing_http_response_access_control_max_age_header_value             = var.lb_listener_routing_http_response_access_control_max_age_header_value
  routing_http_response_content_security_policy_header_value            = var.lb_listener_routing_http_response_content_security_policy_header_value
  routing_http_response_x_content_type_options_header_value             = var.lb_listener_routing_http_response_x_content_type_options_header_value
  routing_http_response_x_frame_options_header_value                    = var.lb_listener_routing_http_response_x_frame_options_header_value
  routing_http_request_x_amzn_mtls_clientcert_serial_number_header_name = var.lb_listener_routing_http_request_x_amzn_mtls_clientcert_serial_number_header_name
  routing_http_request_x_amzn_mtls_clientcert_issuer_header_name        = var.lb_listener_routing_http_request_x_amzn_mtls_clientcert_issuer_header_name
  routing_http_request_x_amzn_mtls_clientcert_subject_header_name       = var.lb_listener_routing_http_request_x_amzn_mtls_clientcert_subject_header_name
  routing_http_request_x_amzn_mtls_clientcert_validity_header_name      = var.lb_listener_routing_http_request_x_amzn_mtls_clientcert_validity_header_name
  routing_http_request_x_amzn_mtls_clientcert_leaf_header_name          = var.lb_listener_routing_http_request_x_amzn_mtls_clientcert_leaf_header_name
  routing_http_request_x_amzn_mtls_clientcert_header_name               = var.lb_listener_routing_http_request_x_amzn_mtls_clientcert_header_name
  routing_http_request_x_amzn_tls_version_header_name                   = var.lb_listener_routing_http_request_x_amzn_tls_version_header_name
  routing_http_request_x_amzn_tls_cipher_suite_header_name              = var.lb_listener_routing_http_request_x_amzn_tls_cipher_suite_header_name
  default_action {
    type  = "forward"
    order = 1
    forward {
      target_group {
        arn    = aws_lb_target_group.app.arn
        weight = 1
      }
      dynamic "stickiness" {
        for_each = length(var.lb_listener_stickiness) > 0 ? [true] : []
        content {
          duration = lookup(var.lb_listener_stickiness, "duration", null)
          enabled  = lookup(var.lb_listener_stickiness, "enabled", null)
        }
      }
    }
  }
  dynamic "mutual_authentication" {
    for_each = length(var.lb_listener_mutual_authentication) > 0 ? [true] : []
    content {
      mode                             = lookup(var.lb_listener_mutual_authentication, "mode", null)
      trust_store_arn                  = lookup(var.lb_listener_mutual_authentication, "trust_store_arn", null)
      ignore_client_certificate_expiry = lookup(var.lb_listener_mutual_authentication, "ignore_client_certificate_expiry", null)
      advertise_trust_store_ca_names   = lookup(var.lb_listener_mutual_authentication, "advertise_trust_store_ca_names", null)
    }
  }
  tags = {
    Name       = "${local.lb_name}-listener"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_route53_record" "alb" {
  count   = var.route53_record_zone_id != null ? 1 : 0
  zone_id = var.route53_record_zone_id
  name    = var.route53_record_name
  type    = var.route53_record_type
  alias {
    name                   = aws_lb.app.dns_name
    zone_id                = aws_lb.app.zone_id
    evaluate_target_health = var.route53_record_alias_evaluate_target_health
  }
}
