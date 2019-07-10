module "label" {
  source     = "git::git@github.com:binbashar/terraform-null-label.git?ref=0.11.1"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  delimiter  = "${var.delimiter}"
  attributes = "${var.attributes}"
  tags       = "${var.tags}"
}

data "aws_iam_policy_document" "default" {
  statement {
    sid = "AWSCloudTrailAclCheck"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl",
    ]

    resources = [
      "arn:aws:s3:::${module.label.id}",
    ]
  }

  statement {
    sid = "AWSCloudTrailWrite"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com", "cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${module.label.id}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
        "bucket-owner-full-control",
      ]
    }
  }
}

module "s3_bucket" {
  source                             = "git::git@github.com:binbashar/terraform-aws-s3-log-storage.git?ref=v0.4.2"
  namespace                          = "${var.namespace}"
  stage                              = "${var.stage}"
  name                               = "${var.name}"
  region                             = "${var.region}"
  acl                                = "${var.acl}"
  policy                             = "${data.aws_iam_policy_document.default.json}"
  force_destroy                      = "${var.force_destroy}"
  versioning_enabled                 = "${var.versioning_enabled}"
  lifecycle_rule_enabled             = "${var.lifecycle_rule_enabled}"
  lifecycle_prefix                   = "${var.lifecycle_prefix}"
  lifecycle_tags                     = "${var.lifecycle_tags}"
  noncurrent_version_expiration_days = "${var.noncurrent_version_expiration_days}"
  noncurrent_version_transition_days = "${var.noncurrent_version_transition_days}"
  standard_transition_days           = "${var.standard_transition_days}"
  glacier_transition_days            = "${var.glacier_transition_days}"
  expiration_days                    = "${var.expiration_days}"
  sse_algorithm                      = "${var.sse_algorithm}"
  kms_master_key_id                  = "${var.kms_master_key_id}"
  delimiter                          = "${var.delimiter}"
  attributes                         = "${var.attributes}"
  tags                               = "${var.tags}"
}
