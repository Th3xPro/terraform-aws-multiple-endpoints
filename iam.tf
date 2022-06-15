module "iam" {
  source                                = "./modules/iam"

  #Setup
  # lambda_names                            = ["city","settler","s3File"]
  # lambda_layers                         = var.lambda_layers
  # api_gw_name                           = module.apigw.api_gw_name
  # api_gw_id                             = module.apigw.api_gw_id
  # sqs_count                             = length(var.sqs_queue_names)
  # sqs_arn_list                          = module.sqs.sqs_queue_arns
  # sqs_policy_action_lists               = var.sqs_policy_action_lists
}