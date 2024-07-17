output "web_url" {
  value = aws_cloudfront_distribution.this.domain_name
}
