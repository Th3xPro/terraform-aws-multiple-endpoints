### CITY LAMBDA ###
module "city_lambda" {
  source            = "./modules/lambda"
  name              = "city"
  runtime           = "nodejs12.x"
  lambda_bucket     = "${aws_s3_bucket.lambda_bucket.id}"
  role              = "${module.iam.lambda_iam_arn}"
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
  role              = "${module.iam.lambda_iam_arn}"
  stage             = var.stage
  object_key        = "${aws_s3_object.lambda_s3_object.key}"
  data_source_code  = "${data.archive_file.lambda_code.output_base64sha256}"
}

### S3 LAMBDA ###
module "s3_lambda" {
  source            = "./modules/lambda"
  name              = "s3File"
  runtime           = "nodejs12.x"
  lambda_bucket     = "${aws_s3_bucket.lambda_bucket.id}"
  role              = "${module.iam.lambda_iam_arn}"
  stage             = var.stage
  object_key        = "${aws_s3_object.lambda_s3_object.key}"
  data_source_code  = "${data.archive_file.lambda_code.output_base64sha256}"
}

### CREATE LOG GROUPS ###
resource "aws_cloudwatch_log_group" "settler_loggroup" {
  name              = "/aws/lambda/${module.settler_lambda.name}"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "city_loggroup" {
  name              = "/aws/lambda/${module.city_lambda.name}"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "s3_loggroup" {
  name              = "/aws/lambda/${module.s3_lambda.name}"
  retention_in_days = 14
}