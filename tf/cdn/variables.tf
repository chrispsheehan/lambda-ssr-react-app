variable "region" {
  type        = string
  description = "The AWS Region to use"
  default     = "us-east-1"
}

variable "base_reference" {
  type = string
}

variable "environment" {
  type = string
}
