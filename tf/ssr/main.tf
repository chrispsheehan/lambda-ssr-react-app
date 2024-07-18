resource "aws_s3_bucket" "ssr_code_bucket" {
  bucket = "${data.aws_caller_identity.current.account_id}-${local.ssr_reference}-ssr-code"
}

resource "aws_s3_object" "ssr_code_zip" {
  bucket        = aws_s3_bucket.ssr_code_bucket.id
  key           = basename(var.lambda_zip_path)
  source        = var.lambda_zip_path
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "static_files" {
  depends_on = [aws_s3_bucket.ssr_code_bucket]
  bucket     = aws_s3_bucket.ssr_code_bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "oac-${local.ssr_reference}"
  description                       = "OAC Policy for ${local.ssr_reference}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_lambda_function" "render" {
  function_name = local.ssr_reference
  handler       = "dist/server.handler"
  runtime       = "nodejs20.x"
  role          = aws_iam_role.lambda_execution_role.arn

  s3_bucket = aws_s3_bucket.ssr_code_bucket.bucket
  s3_key    = aws_s3_object.ssr_code_zip.key

  memory_size = 256
  timeout     = 10

  publish = true

  environment {
    variables = {
      APP_ENV       = "production",
      STAGE         = var.environment,
      STATIC_SOURCE = var.static_files_source
    }
  }
}

resource "aws_lambda_alias" "render_alias" {
  name             = "live"
  function_name    = aws_lambda_function.render.function_name
  function_version = aws_lambda_function.render.version
}

resource "aws_iam_role" "lambda_execution_role" {
  name               = "${local.ssr_reference}-lambda-execution-role"
  assume_role_policy = data.aws_iam_policy_document.api_lambda_assume_role.json
}

resource "aws_iam_role_policy" "s3_access_policy" {
  name   = "${local.ssr_reference}-s3-access-policy"
  role   = aws_iam_role.lambda_execution_role.id
  policy = data.aws_iam_policy_document.s3_access_policy.json
}

resource "aws_lambda_permission" "this" {
  statement_id  = "${local.ssr_reference}-allow-api-gateway-invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.render.function_name
  principal     = "edgelambda.amazonaws.com"
  source_arn    = aws_cloudfront_distribution.this.arn
}

resource "aws_cloudfront_distribution" "this" {
  origin {
    domain_name              = aws_s3_bucket.ssr_code_bucket.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.ssr_code_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id       = aws_s3_bucket.ssr_code_bucket.bucket_regional_domain_name
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = aws_lambda_alias.render_alias.arn
      include_body = false
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
