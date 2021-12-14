output "id" {
  value = aws_apigatewayv2_api.api.id
}

output "endpoint" {
  value = aws_apigatewayv2_api.api.api_endpoint
}

output "integration_ids" {
  value = { for k, v in aws_apigatewayv2_integration.integration : k => v.id }
}

output "default_arn" {
  value = aws_apigatewayv2_stage.stage.execution_arn
}