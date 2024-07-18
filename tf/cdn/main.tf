resource "aws_s3_bucket" "static_files" {
  bucket        = "${data.aws_caller_identity.current.account_id}-${local.static_reference}-files"
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


