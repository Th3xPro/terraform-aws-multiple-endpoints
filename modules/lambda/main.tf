
resource "aws_lambda_function" "lambda_function" {
  function_name     = "${var.name}-handler"
  handler           = "${var.name}.handler"
  runtime           = var.runtime
  role              = var.role
  s3_bucket         = var.lambda_bucket
  s3_key            = var.object_key
  source_code_hash  = var.data_source_code
  memory_size       = 128
  timeout           = 10
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
}

