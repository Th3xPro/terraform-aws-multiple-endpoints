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