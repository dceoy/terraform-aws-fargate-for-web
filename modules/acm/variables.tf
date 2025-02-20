variable "system_name" {
  description = "System name"
  type        = string
}

variable "env_type" {
  description = "Environment type"
  type        = string
}

variable "acm_domain_name" {
  description = "Domain name for which the ACM certificate should be issued"
  type        = string
  default     = null
}

variable "acm_subject_alternative_names" {
  description = "Set of domains that should be SANs in the issued ACM certificate"
  type        = list(string)
  default     = []
}

variable "acm_key_algorithm" {
  description = "Algorithm of the public and private key pair that the issued ACM certificate uses to encrypt data"
  type        = string
  default     = null
  validation {
    condition     = var.acm_key_algorithm == null || contains(["RSA_1024", "RSA_2048", "RSA_3072", "RSA_4096", "EC_prime256v1", "EC_secp384r1", "EC_secp521r1"], var.acm_key_algorithm)
    error_message = "ACM key algorithm must be either RSA_1024, RSA_2048, RSA_3072, RSA_4096, EC_prime256v1, EC_secp384r1, or EC_secp521r1"
  }
}

variable "acm_certificate_transparency_logging_preference" {
  description = "Whether to add ACM certificate details to a certificate transparency log"
  type        = bool
  default     = null
}

variable "route53_record_zone_id" {
  description = "Route 53 record hosted zone ID for the ALB"
  type        = string
  default     = null
}

variable "route53_record_ttl" {
  description = "TTL for the Route 53 record"
  type        = number
  default     = 60
}

variable "acm_validation_timeout_create" {
  description = "Timeout for the ACM certificate validation creation"
  type        = string
  default     = null
}
