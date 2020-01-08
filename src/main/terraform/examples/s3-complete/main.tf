provider "aws" {
  region                  = var.region
  profile                 = var.profile
}

locals {
  bucket_name             = "s3-bucket-${random_pet.this.id}"
}

resource "random_pet" "this" {
  length = 2
}

resource "aws_kms_key" "objects" {
  description             = "KMS key is used to encrypt bucket objects"
  deletion_window_in_days = 7
}

module "s3_bucket" {
  source                  = "../../"
  region                  = var.region
  profile                 = var.profile
  bucket                  = local.bucket_name
  force_destroy           = true
  kms_master_key_id       = aws_kms_key.objects.arn
  sse_algorithm           = "aws:kms"

  tags = {
    Owner                 = "example-s3-complete"
  }

  versioning = {
    enabled               = true
  }

  website = {
    index_document        = "index.html"
    error_document        = "error.html"
    routing_rules         = jsonencode([{
      Condition : {
        KeyPrefixEquals : "docs/"
      },
      Redirect : {
        ReplaceKeyPrefixWith : "documents/"
      }
    }])

  }

  logging = {
    target_bucket         = module.log_bucket.this_s3_bucket_id
    target_prefix         = "log/"
  }

  cors_rule = {
    allowed_methods       = ["PUT", "POST"]
    allowed_origins       = ["https://modules.tf", "https://terraform-aws-modules.modules.tf"]
    allowed_headers       = ["*"]
    expose_headers        = ["ETag"]
    max_age_seconds       = 3000
  }

  lifecycle_rule = [
    {
      id                  = "log"
      enabled             = true
      prefix              = "log/"

      tags = {
        rule              = "log"
        autoclean         = "true"
      }

      transition = [
        {
          days            = 30
          storage_class   = "ONEZONE_IA"
          }, {
          days            = 60
          storage_class   = "GLACIER"
        }
      ]

      expiration = {
        days = 90
      }

      noncurrent_version_expiration = {
        days = 30
      }
    },
    {
      id                  = "log1"
      enabled             = true
      prefix              = "log1/"
      abort_incomplete_multipart_upload_days = 7

      noncurrent_version_transition = [
        {
          days            = 30
          storage_class   = "STANDARD_IA"
        },
        {
          days            = 60
          storage_class   = "ONEZONE_IA"
        },
        {
          days            = 90
          storage_class   = "GLACIER"
        },
      ]

      noncurrent_version_expiration = {
        days              = 300
      }
    },
  ]
}

module "log_bucket" {
  source                  = "../../"
  region                  = var.region
  profile                 = var.profile
  bucket                  = "logs-${local.bucket_name}"
  acl                     = "log-delivery-write"
  force_destroy           = true
  attach_elb_log_delivery_policy = true
  kms_master_key_id       = aws_kms_key.objects.arn
  sse_algorithm           = "aws:kms"
  object_lock_configuration = {
    object_lock_enabled   = "Enabled"
    rule = {
      default_retention = {
        mode              = "COMPLIANCE"
        years             = 5
      }
    }
  }
}
