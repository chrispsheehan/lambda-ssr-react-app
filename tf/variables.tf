variable "region" {
  type        = string
  description = "The AWS Region to use"
  default     = "eu-west-2"
}

variable "environment" {
  type        = string
  description = "environment reference"
  default     = "dev"
}

variable "lambda_zip_path" {
  type = string
}

variable "base_reference" {
  type        = string
  description = "base all other resource descriptions from this"
  default     = "chrispsheehan-lambda-ssr-react"
}