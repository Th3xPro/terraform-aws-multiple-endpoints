# output "complete_invoke_url"   {value = "${aws_api_gateway_deployment.deployment1.invoke_url}${aws_api_gateway_stage.example.stage_name}/${aws_api_gateway_resource.person.path_part}"}
