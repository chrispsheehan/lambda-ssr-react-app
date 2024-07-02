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

variable "lambda-zip-path" {
  type = string
}