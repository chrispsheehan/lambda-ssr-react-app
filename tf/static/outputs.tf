output "static_files_bucket" {
  value = aws_s3_bucket.static_files.bucket
}

output "cloudfront_domain" {
  value = aws_cloudfront_distribution.distribution.domain_name
}
