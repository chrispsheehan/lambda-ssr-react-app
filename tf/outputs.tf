output "static_files_bucket" {
  value = aws_s3_bucket.static_files.bucket
}

output "cloudfront_id" {
  value = aws_cloudfront_distribution.distribution.id
}

output "web_url" {
  value = aws_cloudfront_distribution.distribution.domain_name
}
