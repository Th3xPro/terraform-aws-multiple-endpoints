resource "aws_dynamodb_table" "dynamo_table" {
  name           = "${var.name}-${var.stage}"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = var.hash_key
  attribute {
    name = var.hash_key
    type = "S"
  }
  tags = {
    Name        = "dynamodb-table-${var.name}"
    Environment = var.stage
  }
}