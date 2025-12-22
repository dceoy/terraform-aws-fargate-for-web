provider "aws" {
  alias  = "acm_provider"
  region = var.acm_certificate_region
}
