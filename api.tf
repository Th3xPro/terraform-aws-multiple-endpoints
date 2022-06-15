locals {
  //Complex type of endpoints
  settlers = {
    settlers = {
      method = "GET"
      additional_list = [{
        method = "POST"
        parameter = "{cityId}"
      }]
    }
    settler = {
      method = "PUT"
      additional_list = [{
        method = "GET"
        parameter = "{ID}"
      }]
    }
}
cities = {
    city = {
      method = "POST"
      additional_list = [{
        method = "GET"
        parameter = "{ID}"
      }]
    }
    cities = {
      method = "GET"
      additional_list = []
    }
}
s3File = {
    postFile = {
      method = "SKIP"
      additional_list = [{
        method = "POST"
        parameter = "{fileName}"
      }]
    }
    getFile = {
      method = "SKIP"
      additional_list = [{
        method = "GET"
        parameter = "{file}"
      }]
}
}
}

data "aws_caller_identity" "current" { }

### API ###
resource "aws_api_gateway_account" "demo" {
  cloudwatch_role_arn = "${aws_iam_role.cloudwatch.arn}"
}

resource "aws_iam_role" "cloudwatch" {
  name = "api_gateway_cloudwatch_global"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch" {
  name = "default"
  role = "${aws_iam_role.cloudwatch.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
resource "aws_api_gateway_rest_api" "test_api_gateway" {
  name = "test-api-gateway"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}
resource "aws_api_gateway_api_key" "MyApiKey" {
  name = "my-api-key"
}

module "settler_api" {
  for_each      = local.settlers
  source        = "./modules/api_gateway"
  lambda_name   = "${module.settler_lambda.name}"
  lambda_invoke_arn = "${module.settler_lambda.invoke_arn}"
  region        = "${var.aws_region}"
  account_id    = "${data.aws_caller_identity.current.account_id}"
  rest_api      = "${aws_api_gateway_rest_api.test_api_gateway}"
  stage         = var.stage
  path          = each.key
  method        = each.value.method
  additional    = each.value.additional_list
  api_key       = aws_api_gateway_api_key.MyApiKey
}

module "city_api" {
  for_each      = local.cities
  source        = "./modules/api_gateway"
  lambda_name   = "${module.city_lambda.name}"
  lambda_invoke_arn = "${module.settler_lambda.invoke_arn}"
  region        = "${var.aws_region}"
  account_id    = "${data.aws_caller_identity.current.account_id}"
  rest_api      = "${aws_api_gateway_rest_api.test_api_gateway}"
  stage         = var.stage
  path          = each.key
  method        = each.value.method
  additional    = each.value.additional_list
  api_key       = "${aws_api_gateway_api_key.MyApiKey}"

}
module "s3_api" {
  for_each      = local.s3File
  source        = "./modules/api_gateway"
  lambda_name   = "${module.s3_file.name}"
  lambda_invoke_arn = "${module.settler_lambda.invoke_arn}"
  region        = "${var.aws_region}"
  account_id    = "${data.aws_caller_identity.current.account_id}"
  rest_api      = "${aws_api_gateway_rest_api.test_api_gateway}"
  stage         = var.stage
  path          = each.key
  method        = each.value.method
  additional    = each.value.additional_list
  api_key       = aws_api_gateway_api_key.MyApiKey

}