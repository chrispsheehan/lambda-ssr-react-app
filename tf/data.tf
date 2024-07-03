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

data "aws_iam_policy_document" "s3_allow_public_access" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.static_files_bucket.arn}/public/*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}
