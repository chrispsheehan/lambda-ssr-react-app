variable "region" {
  type        = string
  description = "The AWS Region to use"
  default     = "eu-west-2"
}

variable "base_reference" {
  type        = string
  description = "String to base conponent references from"
}

variable "environment" {
  type        = string
  description = "Reference for environment dev | prod etc"
}

variable "lambda_zip_path" {
  type        = string
  description = "Path to zipped SSR lambda code"
}

variable "auth_lambda_zip_path" {
  type        = string
  description = "Path to zipped Auth lambda code"
}

variable "public_path" {
  type        = string
  description = "Path to server static s3 files from"
}

variable "base_path" {
  type        = string
  description = "Path to server SSR app from"
}
