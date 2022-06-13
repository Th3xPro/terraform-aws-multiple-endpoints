data "aws_caller_identity" "current" { }

provider "aws" {
  region     = var.aws_region
}

resource "random_pet" "lambda_bucket_name" {
  prefix = "learn-terraform-maciek"
  length = 4
}

### run the code ###
resource "null_resource" "lambda_dependencies" {
  provisioner "local-exec" {
    command = "cd ${path.cwd}/code/src && npm install"
  }

  triggers = {
    //index = sha256(file("${path.module}/function/src/index.js"))
    package = sha256(file("${path.cwd}/code/package.json"))
    lock = sha256(file("${path.cwd}/code/package-lock.json"))
    node = sha256(join("",fileset(path.cwd, "code/src/**/*.js")))
  }
}
### zip the code ###
data "archive_file" "lambda_code" {
  type        = "zip"
  source_dir  = "${path.cwd}/code"
  output_path = "${path.cwd}/code.zip"
}

### BUCKET ###
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = random_pet.lambda_bucket_name.id

  //acl           = "private"
  force_destroy = true
}

### BUCKET ###
resource "aws_s3_object" "lambda_s3_object" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "code.zip"
  source = data.archive_file.lambda_code.output_path

  etag  = filemd5(data.archive_file.lambda_code.output_path)
}

### ROLE for LAMBDA ###
resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

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

### LAMBDA ###
module "city_lambda" {
  source            = "./modules/lambda"
  name              = "city"
  runtime           = "nodejs12.x"
  lambda_bucket     = "${aws_s3_bucket.lambda_bucket.id}"
  role              = "${aws_iam_role.lambda_exec.arn}"
  stage             = var.stage
  object_key        = "${aws_s3_object.lambda_s3_object.key}"
  data_source_code  = "${data.archive_file.lambda_code.output_base64sha256}"
}

### LAMBDA ###
module "settler_lambda" {
  source            = "./modules/lambda"
  name              = "settler"
  runtime           = "nodejs12.x"
  lambda_bucket     = "${aws_s3_bucket.lambda_bucket.id}"
  role              = "${aws_iam_role.lambda_exec.arn}"
  stage             = var.stage
  object_key        = "${aws_s3_object.lambda_s3_object.key}"
  data_source_code  = "${data.archive_file.lambda_code.output_base64sha256}"
}

### CREATE API ###
resource "aws_api_gateway_rest_api" "test_api_gateway" {
  name = "test-api-gateway"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

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
    /// Simple type of endpoint
    testing = {
      method = "PUT"
      additional_list = []
    }
}
}
### API ###
module "settler_api" {
  for_each      = local.settlers
  source        = "./modules/api_gateway"
  lambda_name   = "${module.settler_lambda.name}"
  region        = "${var.aws_region}"
  account_id    = "${data.aws_caller_identity.current.account_id}"
  rest_api      = "${aws_api_gateway_rest_api.test_api_gateway}"
  stage_name    = "dev"
  path          = each.key
  method        = each.value.method
  additional    = each.value.additional_list
 }