# Terraform moduleName module

- [Terraform moduleName module](#terraform-modulename-module)
  - [Input Variables](#input-variables)
  - [Variable definitions](#variable-definitions)
    - [name](#name)
    - [description](#description)
    - [tags](#tags)
    - [protocol_type](#protocol_type)
    - [cors_configuration](#cors_configuration)
    - [create_role](#create_role)
    - [policy](#policy)
    - [managed_policies](#managed_policies)
    - [role](#role)
    - [disable_execute_api_endpoint](#disable_execute_api_endpoint)
    - [route_selection_expression](#route_selection_expression)
    - [integrations](#integrations)
  - [Examples](#examples)
    - [`main.tf`](#maintf)
    - [`terraform.tfvars.json`](#terraformtfvarsjson)
    - [`provider.tf`](#providertf)
    - [`variables.tf`](#variablestf)
    - [`outputs.tf`](#outputstf)

## Input Variables
| Name     | Type    | Default   | Example     | Notes   |
| -------- | ------- | --------- | ----------- | ------- |
| name | string |  | "test-apigw" |  |
| description | string | "" | "Description of test apigw" |  |
| tags | map(string) | {} | {"environment": "prod"} | |
| protocol_type | string | "HTTP" |  |  |
| cors_configuration | any | {} | `see below` | <https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-cors.html> |
| create_role | bool | true | false |  |
| policy | list(any) | [] | `see below` |  |
| managed_policies | list(string) | [] | `see below` |  |
| role | string | "" | "arn:aws:iam::319244236588:role/service-role/test-apigw-role" |  |
| disable_execute_api_endpoint | bool | false | true |  |
| route_selection_expression | string | "$request.method $request.path" |  |  |
| integrations | any | {} | `see below` |  |

## Variable definitions

### name
Name of the API Gateway, also used for naming other resources.
```json
"name": "<API GW name>"
```

### description
Description of API gateway.
```json
"description": "<API GW description>"
```

Default:
```json
"description": ""
```

### tags
Tags for created bucket.
```json
"tags": {<map of tag keys and values>}
```

Default:
```json
"tags": {}
```

### protocol_type
Supported protocol, either HTTP or WebSocket, current module supports only HTTP.
```json
"protocol_type": "<protocol type>"
```

Default:
```json
"protocol_type": "HTTP"
```

### cors_configuration
CORS configuration for API gateway.
```json
"cors_configuration": {
  "allow_credentials": <true or false>,
  "allow_headers": [<The set of allowed HTTP headers.>],
  "allow_methods": [<The set of allowed HTTP methods.>],
  "allow_origins": [<The set of allowed origins.>],
  "expose_headers": [<The set of exposed HTTP headers.>],
  "max_age": <The number of seconds that the browser should cache preflight request results.>
}
```

Default:
```json
"cors_configuration": {}
```

### create_role
Specifies if IAM role for the API Gateway invocations will be created in module or externally.
Does not apply for all targets, only for ones taht need it.
`true` - created with module
`false` - created externally
```json
"create_role": <true or false>
```

Default:
```json
"create_role": true
```

### policy
Additional inline policy statements for automatically created role.
Effective only if `create_role` is set to `true`.
```json
"policy": [<list of inline policies>]
```

Default:
```json
"policy": []
```

### managed_policies
Additional managed policies which should be attached to auto-created role.
Effective only if `create_role` is set to `true`.
```json
"managed_policies": [<list of managed policies>]
```

Default:
```json
"managed_policies": []
```

### role
ARN of externally created role. Use in case of `create_role` is set to `false`.
```json
"role": "<role ARN>"
```

Default:
```json
"role": ""
```

### disable_execute_api_endpoint
Disables default automatically generated endpoint and leaves only one on custom domain.
For now leave it on `false` since we are not using custom domain.
```json
"disable_execute_api_endpoint": <true or false>
```

Default:
```json
"disable_execute_api_endpoint": false
```

### route_selection_expression
Route Selection Expression.
```json
"route_selection_expression": "<Route Selection Expression.>"
```

Default:
```json
"route_selection_expression": "$request.method $request.path"
```

### integrations
Map of all integrations an their routes for given API Gateway.
In current module everything is automatically deployed in the `$default` stage.
```json
"integrations": {
  "<integration name>": {
    "integration_uri": "<ARN of AWS Lambda or Step Function>",
    "integration_method": "<HTTP method for integration>",
    "credentials_arn": "<ARN of role used for invocation of Step Function>",
    "request_parameters": {<Additional invocation parameters.>},
    "payload_format_version": "<1.0(used for compatibility with REST API GW) or 2.0>",
    "routes_config": [
      {
        "key": "<combination of action and path i.e. GET /dev> or just $default which will catch all requests on endpoint>",
        "authorization_type": "<NONE or AWS_IAM supported in current version>"
      }
    ]
  }
}
```

`request_parameters` for Step Function:
<https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-develop-integrations-aws-services-reference.html#StepFunctions-StartExecution>
```json
"request_parameters": {
  "StateMachineArn": "<SFN ARN>",
  "Name": "<name of integration>",
  "Input": "<static json input>",
  "Region": "<region of SFN>"
}
```

Default:
```json
"integrations": {}
```

## Examples
### `main.tf`
```terarform
mainContent
```

### `terraform.tfvars.json`
```json
{
  "name": "test-apigw",
  "tags": {
    "environment": "prod"
  },
  "managed_policies": [
    "arn:aws:iam::319244236588:policy/example-managed-policy"
  ],
  "integrations": {
    "test-lambda": {
      "integration_uri": "arn:aws:lambda:us-east-1:319244236588:function:luka-lambda-test",
      "payload_format_version": "2.0",
      "routes_config": [
        {
          "key": "GET /pets",
          "authorization_type": "NONE"
        },
        {
          "key": "$default",
          "authorization_type": "NONE"
        }
      ]
    },
    "test-sfn": {
      "request_parameters": {
        "StateMachineArn": "arn:aws:states:us-east-1:319244236588:stateMachine:luka-test-sfn",
        "Name": "test-sfn-integration",
        "Input": null,
        "Region": "us-east-1"
      },
      "routes_config": [
        {
          "key": "GET /pets2",
          "authorization_type": "NONE"
        }
      ]
    }
  }
}
```

### `provider.tf`
```terraform
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      team : "DataOps",
      purpose : "apigw_test",
      owner : "Luka"
    }
  }
}
```

### `variables.tf`
copy ones from module

### `outputs.tf`
```terraform
output "id" {
  value = module.apigw.id
}

output "endpoint" {
  value = module.apigw.endpoint
}

output "integration_ids" {
  value = module.apigw.integration_ids
}

output "default_arn" {
  value = module.apigw.default_arn
}
```