resource "aws_acm_certificate" "cert" {
  count                     = var.acm_domain_name != null ? 1 : 0
  domain_name               = var.acm_domain_name
  subject_alternative_names = var.acm_subject_alternative_names
  validation_method         = "DNS"
  key_algorithm             = var.acm_key_algorithm
  dynamic "options" {
    for_each = var.acm_certificate_transparency_logging_preference != null ? [true] : []
    content {
      certificate_transparency_logging_preference = var.acm_certificate_transparency_logging_preference ? "ENABLED" : "DISABLED"
    }
  }
  tags = {
    Name       = "${var.system_name}-${var.env_type}-acm-certificate"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "acm" {
  for_each = length(aws_acm_certificate.cert) > 0 && var.route53_record_zone_id != null ? {
    for o in aws_acm_certificate.cert[0].domain_validation_options : o.domain_name => o if !startswith(o.domain_name, "*.")
  } : {}
  zone_id = var.route53_record_zone_id
  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  records = [each.value.resource_record_value]
  ttl     = var.route53_record_ttl
}

resource "aws_acm_certificate_validation" "cert" {
  count                   = length(aws_acm_certificate.cert) > 0 && length(aws_route53_record.acm) > 0 ? 1 : 0
  certificate_arn         = aws_acm_certificate.cert[0].arn
  validation_record_fqdns = values(aws_route53_record.acm)[*].fqdn
  timeouts {
    create = var.acm_validation_timeout_create
  }
}
