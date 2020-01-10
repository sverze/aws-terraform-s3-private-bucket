locals {
  bucket_name                 = "origin-s3-bucket-${random_pet.this.id}"
  destination_bucket_name     = "replica-s3-bucket-${random_pet.this.id}"
  origin_region               = "eu-west-1"
  replica_region              = "eu-central-1"
}

provider "aws" {
  region                      = local.origin_region
  profile                     = var.profile
}

provider "aws" {
  alias                       = "replica"
  region                      = local.replica_region
  profile                     = var.profile
}

data "aws_caller_identity" "current" {}

resource "random_pet" "this" {
  length                      = 2
}

resource "aws_kms_key" "replica" {
  provider                    = aws.replica
  description                 = "S3 bucket replication KMS key"
  deletion_window_in_days     = 7
}

module "replica_bucket" {
  source                      = "../../"
  providers                   = {
    aws                       = aws.replica
  }
  bucket                      = local.destination_bucket_name
  region                      = local.replica_region
  profile                     = var.profile
  kms_master_key_id           = aws_kms_key.replica.arn
}

resource "aws_kms_key" "objects" {
  description                 = "KMS key is used to encrypt bucket objects"
  deletion_window_in_days     = 7
}

module "s3_bucket" {
  source                      = "../../"
  bucket                      = local.bucket_name
  region                      = local.origin_region
  profile                     = var.profile
  kms_master_key_id           = aws_kms_key.objects.arn
  versioning                  = {
    enabled                   = true
  }

  replication_configuration   = {
    rules                     = [{
      id                      = "${local.bucket_name}-replication"
      status                  = "Enabled"

      source_selection_criteria   = {
        sse_kms_encrypted_objects = {
          enabled             = true
        }
      }

      destination             = {
        bucket                = "arn:aws:s3:::${local.destination_bucket_name}"
        storage_class         = "STANDARD"
        replica_kms_key_id    = aws_kms_key.replica.arn
        account_id            = data.aws_caller_identity.current.account_id
          access_control_translation = {
            owner             = "Destination"
          }
      }
    }]
  }
}
