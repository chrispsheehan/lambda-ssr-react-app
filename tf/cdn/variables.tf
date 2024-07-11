variable "region" {
  type        = string
  description = "The AWS Region to use"
  default     = "eu-west-2"
}

variable "base_reference" {
  type = string
}

variable "environment" {
  type = string
}
