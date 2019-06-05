data "aws_region" "current" {}

locals {
  tags = {
    tf_module = "aws-hosted-zone"
  }
}

variable "name" {
  description = "Name of module"
  type = "string"
  default = "aws-hosted-zone"
}

variable "external_domain" {
  description = "External Domain to use in hosted zone"
  type        = string
}

variable "tags" {
  description = "map of custom tags to add to resources"
  type        = map(string)
  default     = {}
}
