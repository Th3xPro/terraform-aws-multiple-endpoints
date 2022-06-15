variable "additional" {
  description = "Specify whether to create or not the default /api/messages path or stop at /api"
}
variable "rest_api" {
  description = "REST API"
}
variable "stage" {
  description = "The stage name for the API deployment"
  default = "dev"
}
variable "account_id" {
  description = "The AWS account ID"
}
variable "method" {
  description = "The HTTP method"
}
variable "path" {
  description = "The path of endpoint"
}
variable "lambda_name" {
  description = "The Name of Lambda to invoke"
}
variable "lambda_invoke_arn" {
    description = "The ARN of Lambda to invoke"

}
variable "region" {
  description = "The AWS region"
}
variable "api_key" {
  description = "Api key"
}
variable "use_api_key" {
  description = "Bool of Api key use"
}
variable "enable_api_logs" {
  description = "Bool of Api logs use"
}
