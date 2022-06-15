output "api-key" {
  value = aws_api_gateway_api_key.MyApiKey.*.value
  sensitive = true
}