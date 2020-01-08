variable "region" {
  description = "The AWS region this bucket should reside in"
  type        = string
}

variable "profile" {
  description = "The AWS profile to use to authenticate using the AWS API"
  type        = string
  default     = "default"
}

variable "bucket" {
  description = "(Optional) The name of the bucket. If omitted, a random unique name will be generated"
  type        = string
  default     = null
}

variable "bucket_prefix" {
  description = "(Optional) Creates a unique bucket name beginning with the specified prefix. Conflicts with bucket."
  type        = string
  default     = null
}

variable "acl" {
  type        = string
  description = "The bucket access control, the only options are - private, log-delivery-write"
  default     = "private"
}

variable "attach_elb_log_delivery_policy" {
  description = "(Optional) Controls if S3 bucket should have ELB log delivery policy attached. False by default"
  type        = bool
  default     = false
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the bucket."
  type        = map(string)
  default     = {}
}

variable "force_destroy" {
  description = "(Optional) Indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable. False by default"
  type        = bool
  default     = false
}

variable "acceleration_status" {
  description = "(Optional) Sets the accelerate configuration of an existing bucket. Can be Enabled or Suspended."
  type        = string
  default     = null
}

variable "request_payer" {
  description = "(Optional) Specifies who should bear the cost of Amazon S3 data transfer. Can be either BucketOwner or Requester. By default, the owner of the S3 bucket would incur the costs of any data transfer. See Requester Pays Buckets developer guide for more information."
  type        = string
  default     = null
}

variable "website" {
  description = "(Optional) Map containing static web-site hosting or redirect configuration."
  type        = map(string)
  default     = {}
}

variable "cors_rule" {
  description = "(Optional) Map containing a rule of Cross-Origin Resource Sharing."
  type        = any # should be `map`, but it produces an error "all map elements must have the same type"
  default     = {}
}

variable "versioning" {
  description = "(Optional) Map containing versioning configuration, enabled by default."
  type        = map(string)
  default     = {
    enabled   = true
  }
}

variable "logging" {
  description = "Map containing access bucket logging configuration."
  type        = map(string)
  default     = {}
}

variable "lifecycle_rule" {
  description = "List of maps containing configuration of object lifecycle management."
  type        = any
  default     = []
}

variable "replication_configuration" {
  description = "Map containing cross-region replication configuration."
  type        = any
  default     = {}
}

variable "kms_master_key_id" {
  description = "KMS key ARN, this is used to encrypt bucket objects for SSE"
  type        = string
}

variable "sse_algorithm" {
  description = "Server side encryption key algorithm used by the KMS master key"
  type        = string
  default     = "aws:kms"
}

variable "object_lock_configuration" {
  description = "Map containing S3 object locking configuration."
  type        = any
  default     = {}
}
