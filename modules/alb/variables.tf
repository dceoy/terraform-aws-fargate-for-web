variable "system_name" {
  description = "System name"
  type        = string
}

variable "env_type" {
  description = "Environment type"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs"
  type        = list(string)
}

variable "lb_logs_s3_bucket_id" {
  description = "S3 bucket ID for ALB logs"
  type        = string
  default     = null
}

variable "lb_security_group_ingress_from_port" {
  description = "Start port for the ALB security group ingress"
  type        = number
  default     = 0
}

variable "lb_security_group_ingress_to_port" {
  description = "End port for the ALB security group ingress"
  type        = number
  default     = 0
}

variable "lb_security_group_ingress_protocol" {
  description = "Protocol for the ALB security group ingress"
  type        = string
  default     = "-1"
}

variable "lb_security_group_ingress_ipv4_cidr_blocks" {
  description = "IPv4 CIDR blocks for the ALB security group ingress"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "lb_security_group_ingress_ipv6_cidr_blocks" {
  description = "IPv6 CIDR blocks for the ALB security group ingress"
  type        = list(string)
  default     = ["::/0"]
}

variable "lb_client_keep_alive" {
  description = "Client keep alive value in seconds for the ALB"
  type        = number
  default     = 3600
  validation {
    condition     = var.lb_client_keep_alive >= 60 && var.lb_client_keep_alive <= 604800
    error_message = "Client keep alive value must be between 60 and 604800 seconds"
  }
}

variable "lb_customer_owned_ipv4_pool" {
  description = "ID of the customer owned ipv4 pool to use for the ALB"
  type        = string
  default     = null
}

variable "lb_desync_mitigation_mode" {
  description = "How the ALB handles requests that might pose a security risk to an application due to HTTP desync"
  type        = string
  default     = "defensive"
  validation {
    condition     = var.lb_desync_mitigation_mode == "monitor" || var.lb_desync_mitigation_mode == "defensive" || var.lb_desync_mitigation_mode == "strictest"
    error_message = "Desync mitigation mode must be monitor, defensive, or strictest"
  }
}

variable "lb_enable_deletion_protection" {
  description = "Whether to disable deletion of the ALB via the AWS API"
  type        = bool
  default     = false
}

variable "lb_enable_http2" {
  description = "Whether to enable HTTP/2 for the ALB"
  type        = bool
  default     = true
}

variable "lb_enable_tls_version_and_cipher_suite_headers" {
  description = "Whether to add x-amzn-tls-version and x-amzn-tls-cipher-suite to the client request before sending it to the target by the ALB"
  type        = bool
  default     = false
}

variable "lb_enable_xff_client_port" {
  description = "Whether the X-Forwarded-For header should preserve the source port that the client used to connect to the ALB"
  type        = bool
  default     = false
}

variable "lb_enable_waf_fail_open" {
  description = "Whether to allow a WAF-enabled ALB to route requests to targets if it is unable to forward the request to AWS WAF"
  type        = bool
  default     = false
}

variable "lb_enable_zonal_shift" {
  description = "Whether to enable zonal shift for the ALB"
  type        = bool
  default     = false
}

variable "lb_idle_timeout" {
  description = "Time in seconds that the connection is allowed to be idle for the ALB"
  type        = number
  default     = 60
}

variable "lb_ip_address_type" {
  description = "Type of IP addresses used by the subnets for the ALB"
  type        = string
  default     = "ipv4"
  validation {
    condition     = var.lb_ip_address_type == "ipv4" || var.lb_ip_address_type == "dualstack" || var.lb_ip_address_type == "dualstack-without-public-ipv4"
    error_message = "IP address type must be ipv4, dualstack, or dualstack-without-public-ipv4"
  }
}

variable "lb_preserve_host_header" {
  description = "Whether the ALB should preserve the Host header in the HTTP request and send it to the target without any change"
  type        = bool
  default     = false
}

variable "lb_xff_header_processing_mode" {
  description = "How the ALB modifies the X-Forwarded-For header in the HTTP request before sending the request to the target"
  type        = string
  default     = "append"
  validation {
    condition     = var.lb_xff_header_processing_mode == "append" || var.lb_xff_header_processing_mode == "preserve" || var.lb_xff_header_processing_mode == "remove"
    error_message = "X-Forwarded-For header processing mode must be append, preserve, or remove"
  }
}

variable "lb_target_group_port" {
  description = "Port on which the ALB target group receives traffic"
  type        = number
  default     = 80
}

variable "lb_target_group_protocol" {
  description = "Protocol to use for routing traffic to the ALB target group"
  type        = string
  default     = "HTTP"
  validation {
    condition     = var.lb_target_group_protocol == "GENEVE" || var.lb_target_group_protocol == "HTTP" || var.lb_target_group_protocol == "HTTPS" || var.lb_target_group_protocol == "TCP" || var.lb_target_group_protocol == "TCP_UDP" || var.lb_target_group_protocol == "TLS" || var.lb_target_group_protocol == "UDP"
    error_message = "Target group protocol must be GENEVE, HTTP, HTTPS, TCP, TCP_UDP, TLS, or UDP"
  }
}

variable "lb_target_group_protocol_version" {
  description = "Protocol version for the ALB target group (only applicable when protocol is HTTP or HTTPS)"
  type        = string
  default     = "HTTP1"
  validation {
    condition     = var.lb_target_group_protocol_version == "HTTP1" || var.lb_target_group_protocol_version == "HTTP2" || var.lb_target_group_protocol_version == "GRPC"
    error_message = "Target group protocol version must be HTTP1, HTTP2, or GRPC"
  }
}

variable "lb_target_group_ip_address_type" {
  description = "Type of IP addresses used by the ALB target group"
  type        = string
  default     = "ipv4"
  validation {
    condition     = var.lb_target_group_ip_address_type == "ipv4" || var.lb_target_group_ip_address_type == "ipv6"
    error_message = "IP address type must be ipv4 or ipv6"
  }
}

variable "lb_target_group_deregistration_delay" {
  description = "Amount of time for the ALB to wait before changing the state of a deregistering target from draining to unused"
  type        = number
  default     = 300
  validation {
    condition     = var.lb_target_group_deregistration_delay >= 0 && var.lb_target_group_deregistration_delay <= 3600
    error_message = "Deregistration delay must be between 0 and 3600 seconds"
  }
}

variable "lb_target_group_load_balancing_algorithm_type" {
  description = "How the ALB selects targets when routing requests"
  type        = string
  default     = "round_robin"
  validation {
    condition     = var.lb_target_group_load_balancing_algorithm_type == "round_robin" || var.lb_target_group_load_balancing_algorithm_type == "least_outstanding_requests" || var.lb_target_group_load_balancing_algorithm_type == "weighted_random"
    error_message = "Load balancing algorithm type must be round_robin, least_outstanding_requests, or weighted_random"
  }
}

variable "lb_target_group_load_balancing_anomaly_mitigation" {
  description = "Whether to enable target anomaly mitigation for the ALB target group"
  type        = string
  default     = "off"
  validation {
    condition     = var.lb_target_group_load_balancing_anomaly_mitigation == "on" || var.lb_target_group_load_balancing_anomaly_mitigation == "off"
    error_message = "Load balancing anomaly mitigation must be on or off"
  }
}

variable "lb_target_group_load_balancing_cross_zone_enabled" {
  description = "Whether to enable cross zone load balancing for the ALB target group"
  type        = string
  default     = "use_load_balancer_configuration"
  validation {
    condition     = var.lb_target_group_load_balancing_cross_zone_enabled == "true" || var.lb_target_group_load_balancing_cross_zone_enabled == "false" || var.lb_target_group_load_balancing_cross_zone_enabled == "use_load_balancer_configuration"
    error_message = "Cross zone load balancing must be true, false, or use_load_balancer_configuration"
  }
}

variable "lb_target_group_preserve_client_ip" {
  description = "Whether to preserve client IP addresses for the ALB target group"
  type        = bool
  default     = false
}

variable "lb_target_group_slow_start" {
  description = "Amount of time for targets to warm up before the ALB sends them a full share of requests"
  type        = number
  default     = 0
  validation {
    condition     = var.lb_target_group_slow_start >= 0 && var.lb_target_group_slow_start <= 900
    error_message = "Slow start must be between 0 and 900 seconds"
  }
}

variable "lb_target_group_stickiness" {
  description = "Stickiness configuration for the ALB target group"
  type        = map(any)
  default     = {}
  validation {
    condition     = alltrue([for k in keys(var.lb_target_group_stickiness) : contains(["cookie_duration", "cookie_name", "enabled", "type"], k)])
    error_message = "Stickiness configuration allows only cookie_duration, cookie_name, enabled, and type as keys"
  }
}

variable "lb_target_group_health_check" {
  description = "Health check configuration for the ALB target group"
  type        = map(any)
  default     = {}
  validation {
    condition     = alltrue([for k in keys(var.lb_target_group_health_check) : contains(["enabled", "healthy_threshold", "interval", "matcher", "path", "port", "protocol", "timeout", "unhealthy_threshold"], k)])
    error_message = "Health check configuration allows only enabled, healthy_threshold, interval, matcher, path, port, protocol, timeout, and unhealthy_threshold as keys"
  }
}

variable "lb_target_group_health_dns_failover" {
  description = "DNS Failover requirements for the ALB target group health"
  type        = map(number)
  default     = {}
  validation {
    condition     = alltrue([for k in keys(var.lb_target_group_health_dns_failover) : contains(["minimum_healthy_targets_count", "minimum_healthy_targets_percentage"], k)])
    error_message = "DNS Failover requirements allows only minimum_healthy_targets_count and minimum_healthy_targets_percentage as keys"
  }
}

variable "lb_target_group_health_unhealthy_state_routing" {
  description = "Unhealthy state routing requirements for the ALB target group health"
  type        = map(number)
  default     = {}
  validation {
    condition     = alltrue([for k in keys(var.lb_target_group_health_unhealthy_state_routing) : contains(["minimum_healthy_targets_count", "minimum_healthy_targets_percentage"], k)])
    error_message = "Unhealthy state routing requirements allows only minimum_healthy_targets_count and minimum_healthy_targets_percentage as keys"
  }
}

variable "lb_listener_port" {
  description = "Port on which the ALB is listening"
  type        = number
  default     = 80
}

variable "lb_listener_protocol" {
  description = "Protocol for connections from clients to the ALB"
  type        = string
  default     = "HTTP"
  validation {
    condition     = var.lb_listener_protocol == "HTTP" || var.lb_listener_protocol == "HTTPS"
    error_message = "Listener protocol must be HTTP or HTTPS"
  }
}

variable "lb_listener_ssl_policy" {
  description = "SSL policy for the ALB listener"
  type        = string
  default     = "ELBSecurityPolicy-2016-08"
}

variable "lb_listener_certificate_arn" {
  description = "ARN of the default SSL server certificate for the ALB listener"
  type        = string
  default     = null
}

variable "lb_listener_routing_http_response_server_enabled" {
  description = "Whether to allow or remove the HTTP response server header"
  type        = bool
  default     = null
}

variable "lb_listener_routing_http_response_strict_transport_security_header_value" {
  description = "Value for the Strict-Transport-Security header in the HTTP response from the ALB listener"
  type        = string
  default     = null
}

variable "lb_listener_routing_http_response_access_control_allow_origin_header_value" {
  description = "Value for the Access-Control-Allow-Origin header in the HTTP response from the ALB listener"
  type        = string
  default     = null
}

variable "lb_listener_routing_http_response_access_control_allow_methods_header_value" {
  description = "Value for the Access-Control-Allow-Methods header in the HTTP response from the ALB listener"
  type        = string
  default     = null
}

variable "lb_listener_routing_http_response_access_control_allow_headers_header_value" {
  description = "Value for the Access-Control-Allow-Headers header in the HTTP response from the ALB listener"
  type        = string
  default     = null
}

variable "lb_listener_routing_http_response_access_control_allow_credentials_header_value" {
  description = "Value for the Access-Control-Allow-Credentials header in the HTTP response from the ALB listener"
  type        = string
  default     = null
}

variable "lb_listener_routing_http_response_access_control_expose_headers_header_value" {
  description = "Value for the Access-Control-Expose-Headers header in the HTTP response from the ALB listener"
  type        = string
  default     = null
}

variable "lb_listener_routing_http_response_access_control_max_age_header_value" {
  description = "Value for the Access-Control-Max-Age header in the HTTP response from the ALB listener"
  type        = number
  default     = null
}

variable "lb_listener_routing_http_response_content_security_policy_header_value" {
  description = "Value for the Content-Security-Policy header in the HTTP response from the ALB listener"
  type        = string
  default     = null
}

variable "lb_listener_routing_http_response_x_content_type_options_header_value" {
  description = "Value for the X-Content-Type-Options header in the HTTP response from the ALB listener"
  type        = string
  default     = null
}

variable "lb_listener_routing_http_response_x_frame_options_header_value" {
  description = "Value for the X-Frame-Options header in the HTTP response from the ALB listener"
  type        = string
  default     = null
}

variable "lb_listener_routing_http_request_x_amzn_mtls_clientcert_serial_number_header_name" {
  description = "Name of the X-Amzn-Mtls-Clientcert-Serial-Number HTTP request header for the ALB listener"
  type        = string
  default     = null
}

variable "lb_listener_routing_http_request_x_amzn_mtls_clientcert_issuer_header_name" {
  description = "Name of the X-Amzn-Mtls-Clientcert-Issuer HTTP request header for the ALB listener"
  type        = string
  default     = null
}

variable "lb_listener_routing_http_request_x_amzn_mtls_clientcert_subject_header_name" {
  description = "Name of the X-Amzn-Mtls-Clientcert-Subject HTTP request header for the ALB listener"
  type        = string
  default     = null
}

variable "lb_listener_routing_http_request_x_amzn_mtls_clientcert_validity_header_name" {
  description = "Name of the X-Amzn-Mtls-Clientcert-Validity HTTP request header for the ALB listener"
  type        = string
  default     = null
}

variable "lb_listener_routing_http_request_x_amzn_mtls_clientcert_leaf_header_name" {
  description = "Name of the X-Amzn-Mtls-Clientcert-Leaf HTTP request header for the ALB listener"
  type        = string
  default     = null
}

variable "lb_listener_routing_http_request_x_amzn_mtls_clientcert_header_name" {
  description = "Name of the X-Amzn-Mtls-Clientcert HTTP request header for the ALB listener"
  type        = string
  default     = null
}

variable "lb_listener_routing_http_request_x_amzn_tls_version_header_name" {
  description = "Name of the X-Amzn-Tls-Version HTTP request header for the ALB listener"
  type        = string
  default     = null
}

variable "lb_listener_routing_http_request_x_amzn_tls_cipher_suite_header_name" {
  description = "Name of the X-Amzn-Tls-Cipher-Suite HTTP request header for the ALB listener"
  type        = string
  default     = null
}

variable "lb_listener_mutual_authentication" {
  description = "Mutual authentication configuration for the ALB listener"
  type        = map(string)
  default     = {}
  validation {
    condition     = alltrue([for k in keys(var.lb_listener_mutual_authentication) : contains(["mode", "trust_store_arn", "ignore_client_certificate_expiry", "advertise_trust_store_ca_names"], k)])
    error_message = "Mutual authentication configuration allows only mode, trust_store_arn, ignore_client_certificate_expiry, and advertise_trust_store_ca_names as keys"
  }
}

variable "lb_listener_stickiness" {
  description = "Target group stickiness configuration for the ALB listener"
  type        = map(any)
  default     = {}
  validation {
    condition     = alltrue([for k in keys(var.lb_listener_stickiness) : contains(["duration", "enabled"], k)])
    error_message = "Stickiness configuration allows only duration and enabled as keys"
  }
}
