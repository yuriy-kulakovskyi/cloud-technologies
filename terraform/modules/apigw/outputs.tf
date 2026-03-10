output "api_id" {
  description = "ID of the API Gateway"
  value       = aws_api_gateway_rest_api.main.id
}

output "api_arn" {
  description = "ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.main.arn
}

output "api_endpoint" {
  description = "Invoke URL of the API Gateway"
  value       = aws_api_gateway_deployment.main.invoke_url
}

output "stage_name" {
  description = "Stage name of the API Gateway"
  value       = aws_api_gateway_stage.main.stage_name
}

output "full_invoke_url" {
  description = "Full invoke URL including stage"
  value       = "${aws_api_gateway_deployment.main.invoke_url}${aws_api_gateway_stage.main.stage_name}"
}
