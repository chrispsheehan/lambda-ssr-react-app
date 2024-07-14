output "static_files_bucket" {
  value = aws_s3_bucket.static_files.bucket
}

output "static_files_cdn" {
  value = "https://${aws_cloudfront_distribution.distribution.domain_name}/public"
}

output "cloudfront_id" {
  value = aws_cloudfront_distribution.distribution.id
}
