data "aws_iam_policy_document" "bucket-assume-role-policy" {
  statement {
    actions       = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = [
        "ec2.amazonaws.com",
        "s3.amazonaws.com"
      ]
    }

    effect        = "Allow"
    sid           = ""
  }
}

resource "aws_iam_role" "bucket_role" {
  assume_role_policy = data.aws_iam_policy_document.bucket-assume-role-policy.json
}

data "aws_iam_policy_document" "bucket_policy" {
  count = var.attach_elb_log_delivery_policy ? 0 : 1

  statement {
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.bucket_role.arn]
    }

    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateObject",
      "s3:GetReplicationConfiguration"
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.this.id}",
      "arn:aws:s3:::${aws_s3_bucket.this.id}/*"
    ]
  }
}

# AWS Load Balancer access log delivery policy
data "aws_elb_service_account" "elb_log_delivery_account" {
  count = var.attach_elb_log_delivery_policy ? 1 : 0
}

data "aws_iam_policy_document" "elb_log_delivery_policy" {
  count = var.attach_elb_log_delivery_policy ? 1 : 0

  statement {
    sid = ""

    principals {
      type        = "AWS"
      identifiers = data.aws_elb_service_account.elb_log_delivery_account.*.arn
    }

    effect        = "Allow"

    actions       = [
      "s3:PutObject",
    ]

    resources     = [
      "arn:aws:s3:::${aws_s3_bucket.this.id}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket          = aws_s3_bucket.this.id
  policy          = var.attach_elb_log_delivery_policy ? data.aws_iam_policy_document.elb_log_delivery_policy[0].json : data.aws_iam_policy_document.bucket_policy[0].json
}
