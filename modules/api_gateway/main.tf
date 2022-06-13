resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = var.rest_api.id
  stage_name = var.stage_name
  depends_on = [
  aws_api_gateway_integration.request_method_integration_base,
  aws_api_gateway_integration.request_method_integration,
  aws_api_gateway_integration_response.response_method_integration,
  aws_api_gateway_integration_response.response_method_integration_base
  ]
   triggers = {
    redeployment = sha1(jsonencode(var.rest_api.body))
  }
  lifecycle {
     create_before_destroy = true
  }
}

resource "aws_api_gateway_resource" "api_resource" {
  parent_id = var.rest_api.root_resource_id
  path_part = var.path
  rest_api_id = var.rest_api.id
}

resource "aws_api_gateway_method" "request_method_base" {
  authorization = "NONE"
  http_method = var.method
  resource_id = "${aws_api_gateway_resource.api_resource.id}"
  rest_api_id = var.rest_api.id
}

resource "aws_api_gateway_integration" "request_method_integration_base" {
  http_method = "${aws_api_gateway_method.request_method_base.http_method}"
  resource_id = "${aws_api_gateway_resource.api_resource.id}"
  rest_api_id = var.rest_api.id
  type = "AWS_PROXY"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${var.account_id}:function:${var.lambda_name}/invocations"
  integration_http_method = var.method
}

resource "aws_api_gateway_method_response" "response_method_base" {
  http_method = "${aws_api_gateway_integration.request_method_integration_base.http_method}"
  resource_id = "${aws_api_gateway_resource.api_resource.id}"
  rest_api_id = var.rest_api.id
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "response_method_integration_base" {
  http_method = "${aws_api_gateway_method_response.response_method_base.http_method}"
  resource_id = "${aws_api_gateway_resource.api_resource.id}"
  rest_api_id = var.rest_api.id
  status_code = "${aws_api_gateway_method_response.response_method_base.status_code}"
}

### ADDITIONAL PARAMETER ###
resource "aws_api_gateway_resource" "messages_resource" {
  count       = length(var.additional) != 0 ? length(var.additional) : 0
  parent_id   = aws_api_gateway_resource.api_resource.id
  path_part   = var.additional[count.index].parameter
  rest_api_id = var.rest_api.id
}

resource "aws_api_gateway_method" "request_method" {
  count         = length(var.additional) != 0 ? length(var.additional) : 0
  authorization = "NONE"
  http_method = var.additional[count.index].method
  resource_id = "${aws_api_gateway_resource.messages_resource[count.index].id}"
  rest_api_id = var.rest_api.id
}

resource "aws_api_gateway_integration" "request_method_integration" {
  count = length(var.additional) != 0 ? length(var.additional) : 0
  http_method = "${aws_api_gateway_method.request_method[count.index].http_method}"
  resource_id = "${aws_api_gateway_resource.messages_resource[count.index].id}"
  rest_api_id = var.rest_api.id
  type = "AWS_PROXY"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${var.account_id}:function:${var.lambda_name}/invocations"
  integration_http_method = var.method
}

resource "aws_api_gateway_method_response" "response_method" {
  count = length(var.additional) != 0 ? length(var.additional) : 0
  http_method = "${aws_api_gateway_integration.request_method_integration[count.index].http_method}"
  resource_id = "${aws_api_gateway_resource.messages_resource[count.index].id}"
  rest_api_id = var.rest_api.id
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "response_method_integration" {
  count = length(var.additional) != 0 ? length(var.additional) : 0
  http_method = "${aws_api_gateway_method_response.response_method[count.index].http_method}"
  resource_id = "${aws_api_gateway_resource.messages_resource[count.index].id}"
  rest_api_id = var.rest_api.id
  status_code = "${aws_api_gateway_method_response.response_method[count.index].status_code}"
}

resource "aws_lambda_permission" "apigw-lambda-allow" {
  function_name = "${var.lambda_name}"
  # statement_id  = "AllowExecutionFromApiGateway"
  action     = "lambda:InvokeFunction"
  principal  = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${var.rest_api.id}/*/${var.method}${var.path}"
  depends_on = [var.rest_api,aws_api_gateway_resource.api_resource,aws_api_gateway_resource.messages_resource]
  }