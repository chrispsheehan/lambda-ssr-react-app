output "api_invoke_url" {
  value = aws_apigatewayv2_stage.this[0].invoke_url
}

output "s3_static_bucket" {
  value = aws_s3_bucket.static_files_bucket.bucket
}
