locals {
  name = coalesce(var.name, var.domain)

  tags = merge(var.tags,
    {
      Name = local.name
    }
  )
}

resource "aws_route53_zone" "this" {
  name = var.domain
  tags = local.tags


  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate" "this" {
  count = var.create_certificate ? 1 : 0

  domain_name               = "*.${var.domain}"
  subject_alternative_names = [var.domain]
  tags                      = local.tags
  validation_method         = "DNS"

  depends_on = [aws_route53_zone.this]

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  dvos = try(tolist(aws_acm_certificate.this[0].domain_validation_options), [{}])
}

resource "aws_route53_record" "this" {
  count = var.create_certificate ? 1 : 0

  allow_overwrite = true
  name            = local.dvos[0].resource_record_name
  records         = [local.dvos[0].resource_record_value]
  ttl             = 60
  type            = local.dvos[0].resource_record_type
  zone_id         = aws_route53_zone.this.zone_id
}

resource "aws_acm_certificate_validation" "this" {
  count = var.create_certificate ? 1 : 0

  certificate_arn         = aws_acm_certificate.this[0].arn
  validation_record_fqdns = [for record in aws_route53_record.this : record.fqdn]
}
