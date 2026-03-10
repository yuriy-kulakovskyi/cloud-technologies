# Output values for the infrastructure

# DynamoDB Tables
output "courses_table_name" {
  description = "Name of the courses DynamoDB table"
  value       = module.courses_table.table_name
}

output "courses_table_arn" {
  description = "ARN of the courses DynamoDB table"
  value       = module.courses_table.table_arn
}

output "authors_table_name" {
  description = "Name of the authors DynamoDB table"
  value       = module.authors_table.table_name
}

output "authors_table_arn" {
  description = "ARN of the authors DynamoDB table"
  value       = module.authors_table.table_arn
}

# Lambda Functions
output "get_all_authors_lambda_arn" {
  description = "ARN of the get-all-authors Lambda function"
  value       = module.get_all_authors_lambda.lambda_function_arn
}

output "get_all_courses_lambda_arn" {
  description = "ARN of the get-all-courses Lambda function"
  value       = module.get_all_courses_lambda.lambda_function_arn
}

output "get_course_lambda_arn" {
  description = "ARN of the get-course Lambda function"
  value       = module.get_course_lambda.lambda_function_arn
}

output "save_course_lambda_arn" {
  description = "ARN of the save-course Lambda function"
  value       = module.save_course_lambda.lambda_function_arn
}

output "update_course_lambda_arn" {
  description = "ARN of the update-course Lambda function"
  value       = module.update_course_lambda.lambda_function_arn
}

output "delete_course_lambda_arn" {
  description = "ARN of the delete-course Lambda function"
  value       = module.delete_course_lambda.lambda_function_arn
}

# API Gateway
output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = module.api_gateway.api_id
}

output "api_gateway_url" {
  description = "Full invoke URL of the API Gateway"
  value       = module.api_gateway.full_invoke_url
}

output "api_gateway_stage" {
  description = "Stage name of the API Gateway"
  value       = module.api_gateway.stage_name
}

# API Endpoints
output "api_endpoints" {
  description = "Available API endpoints"
  value = {
    get_authors     = "${module.api_gateway.full_invoke_url}/authors"
    get_courses     = "${module.api_gateway.full_invoke_url}/courses"
    get_course      = "${module.api_gateway.full_invoke_url}/courses/{id}"
    create_course   = "${module.api_gateway.full_invoke_url}/courses"
    update_course   = "${module.api_gateway.full_invoke_url}/courses/{id}"
    delete_course   = "${module.api_gateway.full_invoke_url}/courses/{id}"
  }
}

# S3 Website
output "website_bucket_name" {
  description = "Name of the S3 bucket hosting the website"
  value       = module.frontend_website.bucket_name
}

output "website_url" {
  description = "URL of the static website"
  value       = module.frontend_website.website_url
}

output "website_endpoint" {
  description = "Website endpoint"
  value       = module.frontend_website.website_endpoint
}

# CloudFront
output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = module.cloudfront.cloudfront_distribution_id
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = module.cloudfront.cloudfront_domain_name
}

output "cloudfront_url" {
  description = "HTTPS URL of the CloudFront distribution"
  value       = module.cloudfront.cloudfront_url
}

# Monitoring & Alerts
output "error_alerts_sns_topic_arn" {
  description = "ARN of the SNS topic for error alerts"
  value       = module.error_alerts_sns.topic_arn
}

output "error_processor_lambda_arn" {
  description = "ARN of the error processor Lambda function"
  value       = module.error_processor_lambda.lambda_function_arn
}

output "monitoring_setup" {
  description = "Monitoring configuration summary"
  value = {
    sns_topic              = module.error_alerts_sns.topic_name
    error_processor        = module.error_processor_lambda.lambda_function_name
    monitored_functions    = [
      "get-all-authors",
      "get-all-courses",
      "get-course",
      "save-course",
      "update-course",
      "delete-course"
    ]
    filter_pattern         = "?ERROR ?CRITICAL ?5xx"
    notifications_enabled  = "Email and Slack (if configured)"
  }
}

