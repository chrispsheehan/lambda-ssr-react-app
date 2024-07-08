output "web_url" {
  value = "${aws_apigatewayv2_stage.this[0].invoke_url}/home"
}
