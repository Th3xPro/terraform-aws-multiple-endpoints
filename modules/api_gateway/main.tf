### DEPLOYMENT ###
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = var.rest_api.id
   triggers   = {
    redeployment = sha1(jsonencode(var.rest_api.body))
  }
  lifecycle {
     create_before_destroy = true
  }
}

resource "aws_api_gateway_resource" "api_resource" {
  parent_id   = var.rest_api.root_resource_id
  path_part   = var.path
  rest_api_id = var.rest_api.id
}

resource "aws_api_gateway_method" "request_method_base" {
  count = var.method != "SKIP" ? 1 : 0
  authorization = "NONE"
  http_method   = var.method
  resource_id   = "${aws_api_gateway_resource.api_resource.id}"
  rest_api_id   = var.rest_api.id
  api_key_required = var.use_api_key
}

resource "aws_api_gateway_method_settings" "example" {
  count = var.enable_api_logs ? 1 : 0
  rest_api_id = var.rest_api.id
  stage_name  = var.stage
  method_path = "*/*"
  settings {
    data_trace_enabled = true
    metrics_enabled    = true
    logging_level      = "ERROR"
  }
}
resource "aws_api_gateway_integration" "request_method_integration_base" {
  count = var.method != "SKIP" ? 1 : 0
  http_method = "${aws_api_gateway_method.request_method_base[0].http_method}"
  resource_id = "${aws_api_gateway_resource.api_resource.id}"
  rest_api_id = var.rest_api.id
  type = "AWS_PROXY"
  uri = var.lambda_invoke_arn
  integration_http_method = "POST"
}

resource "aws_api_gateway_method_response" "response_method_base" {
  count = var.method != "SKIP" ? 1 : 0
  http_method = "${aws_api_gateway_integration.request_method_integration_base[0].http_method}"
  resource_id = "${aws_api_gateway_resource.api_resource.id}"
  rest_api_id = var.rest_api.id
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "response_method_integration_base" {
  count = var.method != "SKIP" ? 1 : 0
  http_method = "${aws_api_gateway_method_response.response_method_base[0].http_method}"
  resource_id = "${aws_api_gateway_resource.api_resource.id}"
  rest_api_id = var.rest_api.id
  status_code = "${aws_api_gateway_method_response.response_method_base[0].status_code}"
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
  http_method   = var.additional[count.index].method
  resource_id   = "${aws_api_gateway_resource.messages_resource[count.index].id}"
  rest_api_id   = var.rest_api.id
  api_key_required = var.use_api_key
}

resource "aws_api_gateway_integration" "request_method_integration" {
  count       = length(var.additional) != 0 ? length(var.additional) : 0
  http_method = "${aws_api_gateway_method.request_method[count.index].http_method}"
  resource_id = "${aws_api_gateway_resource.messages_resource[count.index].id}"
  rest_api_id = var.rest_api.id
  type = "AWS_PROXY"
  uri = var.lambda_invoke_arn
  integration_http_method = "POST"
}

resource "aws_api_gateway_method_response" "response_method" {
  count       = length(var.additional) != 0 ? length(var.additional) : 0
  http_method = "${aws_api_gateway_integration.request_method_integration[count.index].http_method}"
  resource_id = "${aws_api_gateway_resource.messages_resource[count.index].id}"
  rest_api_id = var.rest_api.id
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "response_method_integration" {
  count       = length(var.additional) != 0 ? length(var.additional) : 0
  http_method = "${aws_api_gateway_method_response.response_method[count.index].http_method}"
  resource_id = "${aws_api_gateway_resource.messages_resource[count.index].id}"
  rest_api_id = var.rest_api.id
  status_code = "${aws_api_gateway_method_response.response_method[count.index].status_code}"
}

resource "aws_lambda_permission" "apigw-lambda-allow" {
  function_name = "${var.lambda_name}"
# statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${var.account_id}:${var.rest_api.id}/*/${var.method}/${var.path}"
  depends_on    = [var.rest_api,aws_api_gateway_resource.api_resource,aws_api_gateway_resource.messages_resource]
  }

### STAGE ###
resource "aws_api_gateway_stage" "rest_api_stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = var.rest_api.id
  stage_name    = var.stage
  provisioner "local-exec" {
    command = "Ignore error -> 'Stage already exists' "
    on_failure = continue
  }
}

resource "aws_api_gateway_usage_plan" "example" {
  count        = var.use_api_key ? 1 : 0
  name         = "my-apikey-usage-plan"
  description  = "my description"
  product_code = "MYCODE"

  api_stages {
    api_id = var.rest_api.id
    stage  = aws_api_gateway_stage.rest_api_stage.stage_name
  }

  quota_settings {
    limit  = 1000
    offset = 2
    period = "MONTH"
  }

  throttle_settings {
    burst_limit = 20
    rate_limit  = 5
  }
}
resource "aws_api_gateway_usage_plan_key" "main" {
  count         = var.use_api_key ? 1 : 0
  key_id        = "${var.api_key[count.index].id}"
  key_type      = "API_KEY"
  usage_plan_id = "${aws_api_gateway_usage_plan.example[count.index].id}"
}