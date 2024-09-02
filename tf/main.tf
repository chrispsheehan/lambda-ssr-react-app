resource "aws_s3_bucket" "static_files" {
  bucket        = "${local.static_reference}-files"
  force_destroy = true
}

resource "aws_s3_bucket_cors_configuration" "bucket_cors" {
  bucket = aws_s3_bucket.static_files.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["https://${aws_cloudfront_distribution.distribution.domain_name}"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_ownership_controls" "static_files" {
  depends_on = [aws_s3_bucket.static_files]
  bucket     = aws_s3_bucket.static_files.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_policy" "static_files_policy" {
  bucket = aws_s3_bucket.static_files.id
  policy = data.aws_iam_policy_document.static_files_policy.json
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "oac-${local.static_reference}"
  description                       = "OAC Policy for ${local.static_reference}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "distribution" {

  comment = "${local.static_reference}-cdn"

  origin {
    domain_name              = aws_s3_bucket.static_files.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.static_files.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  enabled         = true
  is_ipv6_enabled = true

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.static_files.bucket_regional_domain_name

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_s3_bucket" "ssr_code_bucket" {
  bucket = "${local.ssr_reference}-ssr-code"
}

resource "aws_s3_object" "ssr_code_zip" {
  bucket        = aws_s3_bucket.ssr_code_bucket.id
  key           = basename(var.lambda_zip_path)
  source        = var.lambda_zip_path
  force_destroy = true
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

  environment {
    variables = {
      APP_ENV       = "production",
      STAGE         = var.environment,
      STATIC_SOURCE = var.static_files_source
    }
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name               = "${local.ssr_reference}-lambda-execution-role"
  assume_role_policy = data.aws_iam_policy_document.api_lambda_assume_role.json
}

resource "aws_lambda_permission" "this" {
  statement_id  = "${local.ssr_reference}-allow-api-gateway-invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.render.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_apigatewayv2_api" "this" {
  name          = local.ssr_reference
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "this" {
  count = 1 # Force recreation every time

  api_id      = aws_apigatewayv2_api.this.id
  name        = var.environment
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = 10
    throttling_rate_limit  = 5
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_apigatewayv2_integration" "this" {
  api_id             = aws_apigatewayv2_api.this.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.render.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "this" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.this.id}"
}

resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.this.id}"
}

