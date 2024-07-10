module "ssr" {
  source = "./ssr"

  environment         = var.environment
  base_reference      = var.base_reference
  lambda_zip_path     = var.lambda_zip_path
  static_files_source = module.static.cloudfront_domain
}

module "static" {
  source = "./static"

  environment    = var.environment
  base_reference = var.base_reference
}
