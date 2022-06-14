resource "random_pet" "lambda_bucket_name" {
  prefix = "learn-terraform-maciek"
  length = 4
}

### run the code ###
resource "null_resource" "lambda_dependencies" {
  provisioner "local-exec" {
    command = "cd ${path.cwd}/code && npm install"
  }

  triggers = {
    //index = sha256(file("${path.module}/function/src/index.js"))
    package = sha256(file("${path.cwd}/code/package.json"))
    lock    = sha256(file("${path.cwd}/code/package-lock.json"))
    node    = sha256(join("",fileset(path.cwd, "code/src/**/*.js")))
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

### CREATE LOGS ###
resource "aws_cloudwatch_log_group" "settler_loggroup" {
  name              = "/aws/lambda/${module.settler_lambda.name}"
  retention_in_days = 14

  lifecycle {
     create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "city_loggroup" {
  name              = "/aws/lambda/${module.city_lambda.name}"
  retention_in_days = 14

  lifecycle {
     create_before_destroy = true
  }
}
### CITY LAMBDA ###
module "city_lambda" {
  source            = "./modules/lambda"
  name              = "city"
  runtime           = "nodejs12.x"
  lambda_bucket     = "${aws_s3_bucket.lambda_bucket.id}"
#   role              = "${aws_iam_role.lambda_exec.arn}"
  stage             = var.stage
  object_key        = "${aws_s3_object.lambda_s3_object.key}"
  data_source_code  = "${data.archive_file.lambda_code.output_base64sha256}"
}

### SETTLER LAMBDA ###
module "settler_lambda" {
  source            = "./modules/lambda"
  name              = "settler"
  runtime           = "nodejs12.x"
  lambda_bucket     = "${aws_s3_bucket.lambda_bucket.id}"
#   role              = "${aws_iam_role.lambda_exec.arn}"
  stage             = var.stage
  object_key        = "${aws_s3_object.lambda_s3_object.key}"
  data_source_code  = "${data.archive_file.lambda_code.output_base64sha256}"
}

module "s3_file" {
  source            = "./modules/lambda"
  name              = "s3File"
  runtime           = "nodejs12.x"
  lambda_bucket     = "${aws_s3_bucket.lambda_bucket.id}"
#   role              = "${aws_iam_role.lambda_exec.arn}"
  stage             = var.stage
  object_key        = "${aws_s3_object.lambda_s3_object.key}"
  data_source_code  = "${data.archive_file.lambda_code.output_base64sha256}"
}