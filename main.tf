locals {
  sfn_arns = compact([for k, v in var.integrations : lookup(lookup(v, "request_parameters", {}), "StateMachineArn", "")])
  routes = flatten(values({ for k,v in var.integrations : k => [ for i in lookup(v, "routes_config", []) : merge(i, {"integration" = k}) ] }))
  routes_final = { for i in local.routes : format("%s_%s", i.integration, replace(lower(i.key), " ", "")) => i }
}

resource "aws_apigatewayv2_api" "api" {
  name          = var.name
  description   = var.description
  protocol_type = var.protocol_type

  dynamic "cors_configuration" {
    for_each = var.cors_configuration != {} ? [true] : []

    content {
      allow_credentials = lookup(var.cors_configuration, "allow_credentials", null)
      allow_headers     = lookup(var.cors_configuration, "allow_headers", null)
      allow_methods     = lookup(var.cors_configuration, "allow_methods", null)
      allow_origins     = lookup(var.cors_configuration, "allow_origins", null)
      expose_headers    = lookup(var.cors_configuration, "expose_headers", null)
      max_age           = lookup(var.cors_configuration, "max_age", null)
    }
  }

  disable_execute_api_endpoint = var.disable_execute_api_endpoint
  route_selection_expression   = var.route_selection_expression
}

resource "aws_apigatewayv2_integration" "integration" {
  for_each = var.integrations

  api_id              = aws_apigatewayv2_api.api.id
  integration_type    = try(regex("^http", lookup(each.value, "integration_uri", null)), "") != "http" ? "AWS_PROXY" : "HTTP_PROXY"
  integration_subtype = try(contains(keys(lookup(each.value, "request_parameters", null)), "StateMachineArn"), false) ? "StepFunctions-StartExecution" : null
  integration_uri     = lookup(each.value, "integration_uri", null)
  integration_method  = lookup(each.value, "integration_method", null)
  credentials_arn     = length(lookup(each.value, "credentials_arn", "")) != 0 ? lookup(each.value, "credentials_arn", "") : try(contains(keys(lookup(each.value, "request_parameters", null)), "StateMachineArn"), false) ? aws_iam_role.apigw_role[0].arn : null

  request_parameters     = lookup(each.value, "request_parameters", null)
  payload_format_version = lookup(each.value, "payload_format_version", null)
}

resource "aws_apigatewayv2_route" "route" {
  for_each = local.routes_final

  api_id = aws_apigatewayv2_api.api.id
  route_key = lookup(each.value, "key", null)
  authorization_type = lookup(each.value, "authorization_type", null)
  target = format("integrations/%s", aws_apigatewayv2_integration.integration[each.value.integration].id)
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id = aws_apigatewayv2_api.api.id
  name = "$default"
  auto_deploy = true
}

resource "aws_iam_role" "apigw_role" {
  count = var.create_role ? 1 : 0
  name  = format("APIGateway-role-%s", var.name)
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"]

  dynamic "inline_policy" {
    for_each = length(local.sfn_arns) != 0 ? [true] : []
    content {
      name = "StepFunctionAccess"
      policy = jsonencode({
        "Version" = "2012-10-17",
        "Statement" = [
          {
            "Sid"      = "sfnaccess"
            "Effect"   = "Allow"
            "Action"   = ["states:StartExecution"]
            "Resource" = local.sfn_arns
          }
        ]
      })
    }
  }
}