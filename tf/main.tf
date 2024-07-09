module "ssr" {
  source = "./ssr"

  environment     = var.environment
  base_reference  = var.base_reference
  lambda-zip-path = var.lambda-zip-path
}

module "static" {
  source = "./static"

  environment    = var.environment
  base_reference = var.base_reference
}
