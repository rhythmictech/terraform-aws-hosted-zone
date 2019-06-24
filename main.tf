provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

resource "aws_route53_zone" "this" {
  name = var.external_domain

  tags = merge(
    local.tags,
    var.tags,
    {
      Name = "var.name"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate" "cert" {
  depends_on = [aws_route53_zone.this]
  domain_name = "*.${var.external_domain}"
  validation_method = "DNS"

  subject_alternative_names = [
    var.external_domain,
  ]

  tags = merge(
    local.tags,
    var.tags,
    {
      Name = "${var.name}-cert"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  name    = aws_acm_certificate.cert.domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.cert.domain_validation_options[0].resource_record_type
  zone_id = aws_route53_zone.this.zone_id
  records = [aws_acm_certificate.cert.domain_validation_options[0].resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate" "cert-east" {
  # if region is us-east-1, set count to 0, otherwise set count to 1
  # This allows us to only create the extra cert if we aren't already using us-east-1
  # Terraform's regex parser was broken when I wrote this so I couldn't use \w or \d
  count = replace(
    replace(data.aws_region.current.name, "us-east-1", "0"),
    "/^[a-z].*[0-9]$/",
    "1",
  )

  depends_on = [aws_route53_zone.this]
  provider    = aws.us-east-1
  domain_name = "*.${var.external_domain}"
  subject_alternative_names = [var.external_domain]
  validation_method = "DNS"

  tags = merge(
    local.tags,
    var.tags,
    {
      Name = "${var.name}-cert-east"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}
