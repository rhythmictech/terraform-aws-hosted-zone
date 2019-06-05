output "zone_id" {
  description = "Zone ID"
  value       = aws_route53_zone.this.zone_id
}

output "zone_name" {
  description = "Zone name"
  value       = var.external_domain
}

output "nameservers" {
  description = "Zone Name Servers"
  value       = flatten(aws_route53_zone.this.name_servers)
}

output "ssl_certificate_arn" {
  description = "ACM SSL Certificate ARN"
  value       = aws_acm_certificate.cert.arn
}

