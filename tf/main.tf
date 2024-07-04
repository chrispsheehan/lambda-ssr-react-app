resource "aws_s3_bucket" "ssr_code_bucket" {
  bucket = "${local.ssr_reference}-ssr-code"
}
resource "aws_s3_object" "ssr_code_zip" {
  bucket        = aws_s3_bucket.ssr_code_bucket.id
  key           = basename(var.lambda-zip-path)
  source        = var.lambda-zip-path
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
      NODE_ENV = "production",
      STATIC_DIR = "/var/task/dist/public/static",
      STAGE = var.environment
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
