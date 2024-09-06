resource "aws_s3_bucket" "static_files" {
  bucket        = "${local.static_origin}-files"
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
  name                              = "oac-${local.reference}"
  description                       = "OAC Policy for ${local.reference}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "distribution" {

  comment = "${local.reference}-distribution"

  origin {
    domain_name              = aws_s3_bucket.static_files.bucket_regional_domain_name
    origin_id                = local.static_origin
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  origin {
    domain_name = replace(
      replace(aws_apigatewayv2_stage.this.invoke_url, "https://", ""),
      "/${aws_apigatewayv2_stage.this.name}",
      ""
    )
    origin_id   = local.ssr_origin
    origin_path = "/${aws_apigatewayv2_stage.this.name}"

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_keepalive_timeout = 5
      origin_read_timeout      = 30
    }

    custom_header {
      name  = "Authorization"
      value = aws_ssm_parameter.api_key_ssm.value
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.ssr_origin

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

  ordered_cache_behavior {
    path_pattern           = "/public/*"
    target_origin_id       = local.static_origin
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
    compress    = true
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
  bucket = "${local.ssr_origin}-code"
}

resource "aws_s3_object" "ssr_code_zip" {
  bucket        = aws_s3_bucket.ssr_code_bucket.id
  key           = basename(var.lambda_zip_path)
  source        = var.lambda_zip_path
  force_destroy = true
}

resource "aws_lambda_function" "render" {
  function_name = local.ssr_origin
  handler       = "app/dist/server.handler"
  runtime       = local.lambda_runtime
  role          = aws_iam_role.lambda_execution_role.arn

  s3_bucket = aws_s3_bucket.ssr_code_bucket.bucket
  s3_key    = aws_s3_object.ssr_code_zip.key

  memory_size = 256
  timeout     = 10

  environment {
    variables = {
      APP_ENV       = "production",
      PUBLIC_PATH   = var.public_path,
      BASE_PATH     = var.base_path,
      STATIC_SOURCE = "NOT_USED"
    }
  }
}

resource "aws_s3_bucket" "auth_code_bucket" {
  bucket = local.auth_reference
}

resource "aws_s3_object" "auth_code_zip" {
  bucket        = aws_s3_bucket.auth_code_bucket.id
  key           = basename(var.auth_lambda_zip_path)
  source        = var.auth_lambda_zip_path
  force_destroy = true
}

resource "random_string" "api_key" {
  length  = 32
  special = false
}

resource "aws_ssm_parameter" "api_key_ssm" {
  name        = "/${local.auth_reference}/api_key"
  description = "API key for ${local.auth_reference}"
  type        = "SecureString"
  value       = random_string.api_key.result
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "${local.auth_reference}-role"
  assume_role_policy = data.aws_iam_policy_document.api_lambda_assume_role.json
}

resource "aws_iam_policy" "lambda_policy" {
  name   = "${local.auth_reference}-logging-policy"
  policy = data.aws_iam_policy_document.lambda_ssm_policy.json //check this
}

resource "aws_iam_role_policy_attachment" "auth" {
  role = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_cloudwatch_log_group" "lambda_auth_log_group" {
  name              = "/aws/lambda/${local.auth_reference}"
  retention_in_days = 1
}

resource "aws_lambda_function" "auth" {
  depends_on    = [ aws_cloudwatch_log_group.lambda_auth_log_group ]

  function_name = local.auth_reference
  handler       = "auth/dist/auth.handler"
  runtime       = local.lambda_runtime
  role          = aws_iam_role.lambda_execution_role.arn

  s3_bucket = aws_s3_bucket.auth_code_bucket.bucket
  s3_key    = aws_s3_object.auth_code_zip.key

  memory_size = 256
  timeout     = 10

  environment {
    variables = {
      API_KEY      = aws_ssm_parameter.api_key_ssm.value
      API_RESOURCE = "${aws_apigatewayv2_stage.this.arn}/GET/*"
    }
  }
}

resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "${local.ssr_origin}-auth-allow-api-gateway-invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auth.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_iam_role" "lambda_execution_role" {
  name               = "${local.ssr_origin}-lambda-execution-role"
  assume_role_policy = data.aws_iam_policy_document.api_lambda_assume_role.json
}

resource "aws_lambda_permission" "this" {
  statement_id  = "${local.ssr_origin}-allow-api-gateway-invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.render.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_apigatewayv2_api" "this" {
  name          = local.ssr_origin
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = var.environment
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = 10
    throttling_rate_limit  = 5
  }
}

resource "aws_apigatewayv2_authorizer" "this" {
  api_id          = aws_apigatewayv2_api.this.id
  authorizer_type = "REQUEST"
  authorizer_uri  = aws_lambda_function.auth.invoke_arn

  identity_sources = ["$request.header.Authorization"]

  name                              = local.auth_reference
  authorizer_payload_format_version = "2.0"
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

  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.this.id
}

resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.this.id}"

  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.this.id
}
