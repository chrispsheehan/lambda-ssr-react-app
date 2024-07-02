terraform {
  required_version = ">= 1.0.8"
  required_providers {
    aws = {
      version = ">= 4.15.0"
      source  = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "chrispsheehan-lambda-ssr-react-app-tfstate"
    key            = "state/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "chrispsheehan-lambda-ssr-react-app-tf-lockid"
  }
}

provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "acm_cert_region"
  region = local.acm_cert_region
}

