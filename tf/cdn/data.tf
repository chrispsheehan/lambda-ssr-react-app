data "aws_caller_identity" "current" {}
data "aws_iam_policy_document" "static_files_policy" {
  version = "2012-10-17"

  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.static_files.arn}/public/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "AWS:SourceArn"
      values   = ["${aws_cloudfront_distribution.distribution.arn}"]
    }
  }
}