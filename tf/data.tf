data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "api_lambda_assume_role" {
  version = "2012-10-17"

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

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

data "aws_iam_policy_document" "lambda_ssm_policy" {
  statement {
    actions   = ["ssm:GetParameter"]
    resources = [aws_ssm_parameter.api_key_ssm.arn] /// create separate one for auth + render
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}
