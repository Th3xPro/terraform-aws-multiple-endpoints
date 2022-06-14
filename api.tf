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
resource "aws_api_gateway_rest_api" "test_api_gateway" {
  name = "test-api-gateway"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}
resource "aws_api_gateway_api_key" "MyApiKey" {
  name = "demo"
}

module "settler_api" {
  for_each      = local.settlers
  source        = "./modules/api_gateway"
  lambda_name   = "${module.settler_lambda.name}"
  region        = "${var.aws_region}"
  account_id    = "${data.aws_caller_identity.current.account_id}"
  rest_api      = "${aws_api_gateway_rest_api.test_api_gateway}"
  stage         = var.stage
  path          = each.key
  method        = each.value.method
  additional    = each.value.additional_list
}

module "city_api" {
  for_each      = local.cities
  source        = "./modules/api_gateway"
  lambda_name   = "${module.city_lambda.name}"
  region        = "${var.aws_region}"
  account_id    = "${data.aws_caller_identity.current.account_id}"
  rest_api      = "${aws_api_gateway_rest_api.test_api_gateway}"
  stage         = var.stage
  path          = each.key
  method        = each.value.method
  additional    = each.value.additional_list
}
module "s3_api" {
  for_each      = local.s3File
  source        = "./modules/api_gateway"
  lambda_name   = "${module.s3_file.name}"
  region        = "${var.aws_region}"
  account_id    = "${data.aws_caller_identity.current.account_id}"
  rest_api      = "${aws_api_gateway_rest_api.test_api_gateway}"
  stage         = var.stage
  path          = each.key
  method        = each.value.method
  additional    = each.value.additional_list
}