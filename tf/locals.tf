locals {
  reference     = "${var.environment}-${var.base_reference}"
  ssr_origin    = "${local.reference}-app"
  static_origin = "${local.reference}-static"
}
