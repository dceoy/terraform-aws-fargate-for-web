output "acm_certificate_arn" {
  description = "ACM certificate ARN"
  value       = length(aws_acm_certificate.cert) > 0 ? aws_acm_certificate.cert[0].arn : null
}

output "acm_certificate_status" {
  description = "ACM certificate status"
  value       = length(aws_acm_certificate.cert) > 0 ? aws_acm_certificate.cert[0].status : null
}

output "acm_certificate_domain_validation_options" {
  description = "List of domain validation objects used to complete ACM certificate validation"
  value       = length(aws_acm_certificate.cert) > 0 ? aws_acm_certificate.cert[0].domain_validation_options : null
}

output "acm_route53_record_names" {
  description = "Names of the Route 53 record for ACM certificate validation"
  value       = { for k, v in aws_route53_record.acm : k => v.name }
}

output "acm_route53_record_fqdns" {
  description = "FQDNs of the Route 53 record for ACM certificate validation"
  value       = { for k, v in aws_route53_record.acm : k => v.fqdn }
}
