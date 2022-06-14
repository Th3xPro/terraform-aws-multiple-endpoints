resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda_${var.name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging_${var.name}"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
         "dynamodb:GetItem",
         "dynamodb:PutItem",
         "dynamodb:Scan",
         "dynamodb:BatchWriteItem",
         "s3:GetObject",
         "s3:PutObject",
         "s3:DeleteObject",
         "logs:CreateLogStream",
         "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_lambda_function" "lambda_function" {
  function_name     = "${var.name}-handler"
  handler           = "${var.name}.handler"
  runtime           = var.runtime
  role              = aws_iam_role.lambda_exec.arn
  s3_bucket         = var.lambda_bucket
  s3_key            = var.object_key
  source_code_hash  = var.data_source_code
  memory_size       = 128
  timeout           = 10
}


resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
}

