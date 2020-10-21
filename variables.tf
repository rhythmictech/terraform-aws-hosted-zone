variable "create_certificate" {
  default     = true
  description = "Create an ACM certificate associated with the domain"
  type        = bool
}

variable "name" {
  default     = null
  description = "Name tag to apply (will default to `external_domain` if not specified)"
  type        = string
}

variable "domain" {
  description = "Domain for hosted zone"
  type        = string
}

variable "tags" {
  default     = {}
  description = "Custom tags to add to resources"
  type        = map(string)
}
