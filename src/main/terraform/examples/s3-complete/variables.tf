variable "region" {
  description = "The AWS region this bucket should reside in. Otherwise, the region used by the callee."
  type        = string
}

variable "profile" {
  description = "The AWS profile to use to authenticate using the AWS API"
  type        = string
  default     = "default"
}
