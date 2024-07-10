variable "base_reference" {
  type = string
}

variable "environment" {
  type = string
}

variable "lambda_zip_path" {
  type = string
}

variable "static_files_source" {
  description = "Cloudfront distribution containing the static files to serve on render"
  type        = string
}