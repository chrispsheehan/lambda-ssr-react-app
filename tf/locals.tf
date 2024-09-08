locals {
  lambda_runtime = "nodejs20.x"
  reference      = "${var.environment}-${var.base_reference}"
  auth_reference = "${local.ssr_origin}-auth"
  ssr_origin     = "${local.reference}-app"
  static_origin  = "${local.reference}-static"
}
