variable "name" {
  description = "Name of API Gateway."
  type        = string
}

variable "description" {
  description = "Descriptio of API GW."
  type        = string
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Tags for S3 bucket"
  default     = {}
}

variable "protocol_type" {
  description = "Protocol for API Gateway. Current support only for HTTP, other option is WebSocket."
  type        = string
  default     = "HTTP"
}

variable "cors_configuration" {
  description = "Map of CORS configuration. https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-cors.html"
  type        = any
  default     = {}
}

variable "create_role" {
  description = "Specifies should role be created with module or will there be external one provided."
  type        = bool
  default     = true
}

variable "policy" {
  description = "List of additional policies for API GW role."
  type        = list(any)
  default     = []
}

variable "managed_policies" {
  description = "List of additional managed policies."
  type        = list(string)
  default     = []
}

variable "role" {
  description = "Custom role ARN used for API GW integrations."
  type        = string
  default     = ""
}

variable "disable_execute_api_endpoint" {
  description = "Disables default API URL and allow only one with custom domain."
  type        = bool
  default     = false
}

variable "route_selection_expression" {
  description = "Route Selection Expression."
  type        = string
  default     = "$request.method $request.path"
}

variable "integrations" {
  description = "Map of all integrations for API GW."
  type        = any
  default     = {}
}