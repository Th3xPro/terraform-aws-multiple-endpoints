# output "api_url" {
#   value = element(compact(concat(tolist(["default"]), aws_api_gateway_deployment.deployment.*.invoke_url)), 0)
# }

# output "api_gw_id" {
#   value = var.rest_api.id
# }

# output "api_gw_name" {
#   value = var.rest_api.name
# }

# output "api_gw_root_resource_id" {
#   value = var.rest_api.root_resource_id
# }

# output "api_gw_api_resource_id" {
#   value = aws_api_gateway_resource.api_resource.id
# }

# output "api_gw_message_resource_id" {
#   //Done due to Terraform inability to evaluate one side of assertion and stop there if valid
#   value = element(compact(concat(tolist(["default"]), aws_api_gateway_resource.messages_resource.*.id)), 0)
# }