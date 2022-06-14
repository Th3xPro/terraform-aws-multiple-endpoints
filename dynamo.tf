 locals {
  dynamo_tables = {
  Settler-Table = {
    hash_key = "ID"
  }
  City-Table = {
    hash_key = "ID"
  }
}
}

 ### DYNAMO ###
 module "aws_dynamodb_table" {
  source   = "./modules/dynamo_db"
  for_each = local.dynamo_tables
  name     = each.key
  hash_key = each.value.hash_key
  stage    = var.stage
}