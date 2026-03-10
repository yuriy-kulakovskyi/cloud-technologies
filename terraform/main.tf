# main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS provider
provider "aws" {
  region = "eu-central-1"
}

# DynamoDB Tables
module "courses_table" {
  source = "./modules/dynamodb/courses"
  
  table_name   = "courses"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  
  attributes = [
    {
      name = "id"
      type = "S"
    }
  ]
  
  tags = {
    Name        = "courses-table"
    Environment = "dev"
  }
}

module "authors_table" {
  source = "./modules/dynamodb/authors"
  
  table_name   = "authors"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  
  attributes = [
    {
      name = "id"
      type = "S"
    }
  ]
  
  tags = {
    Name        = "authors-table"
    Environment = "dev"
  }
}

# Lambda Functions
module "get_all_authors_lambda" {
  source = "./modules/lambda/get-all-authors"
}

module "get_all_courses_lambda" {
  source = "./modules/lambda/get-all-courses"
}

module "get_course_lambda" {
  source = "./modules/lambda/get-course"
}

module "save_course_lambda" {
  source = "./modules/lambda/save-course"
}

module "update_course_lambda" {
  source = "./modules/lambda/update-course"
}

module "delete_course_lambda" {
  source = "./modules/lambda/delete-course"
}

# API Gateway
module "api_gateway" {
  source = "./modules/apigw"
  
  api_name        = "courses-api"
  api_description = "REST API for courses and authors management"
  stage_name      = "prod"
  
  # Get All Authors Lambda
  get_all_authors_lambda_arn        = module.get_all_authors_lambda.lambda_function_arn
  get_all_authors_lambda_invoke_arn = module.get_all_authors_lambda.lambda_invoke_arn
  
  # Get All Courses Lambda
  get_all_courses_lambda_arn        = module.get_all_courses_lambda.lambda_function_arn
  get_all_courses_lambda_invoke_arn = module.get_all_courses_lambda.lambda_invoke_arn
  
  # Get Course Lambda
  get_course_lambda_arn        = module.get_course_lambda.lambda_function_arn
  get_course_lambda_invoke_arn = module.get_course_lambda.lambda_invoke_arn
  
  # Save Course Lambda
  save_course_lambda_arn        = module.save_course_lambda.lambda_function_arn
  save_course_lambda_invoke_arn = module.save_course_lambda.lambda_invoke_arn
  
  # Update Course Lambda
  update_course_lambda_arn        = module.update_course_lambda.lambda_function_arn
  update_course_lambda_invoke_arn = module.update_course_lambda.lambda_invoke_arn
  
  # Delete Course Lambda
  delete_course_lambda_arn        = module.delete_course_lambda.lambda_function_arn
  delete_course_lambda_invoke_arn = module.delete_course_lambda.lambda_invoke_arn
  
  tags = {
    Name        = "courses-api-gateway"
    Environment = "dev"
  }
}

# S3 Static Website
module "frontend_website" {
  source = "./modules/s3-website"
  
  bucket_name      = "courses-app-frontend-${data.aws_caller_identity.current.account_id}"
  build_directory  = "${path.module}/../react-app-frontend/build"
  
  tags = {
    Name        = "courses-frontend"
    Environment = "dev"
  }
}

# CloudFront Distribution
module "cloudfront" {
  source = "./modules/cloudfront"
  
  bucket_regional_domain_name = module.frontend_website.bucket_regional_domain_name
  website_endpoint            = module.frontend_website.website_endpoint
  bucket_id                   = module.frontend_website.bucket_name
  distribution_comment        = "CloudFront distribution for courses React app"
  
  tags = {
    Name        = "courses-frontend-cdn"
    Environment = "dev"
  }
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# SNS Topic for Error Notifications
module "error_alerts_sns" {
  source = "./modules/sns"
  
  topic_name    = "lambda-error-alerts"
  display_name  = "Lambda Error Notifications"
  email_addresses = [
    "yurii.kulakovskyi.ri.2024@lpnu.ua"
  ]
  
  tags = {
    Name        = "lambda-error-alerts"
    Environment = "dev"
  }
}

# Error Processor Lambda Function
module "error_processor_lambda" {
  source = "./modules/lambda/error-processor"
  
  function_name         = "lambda-error-processor"
  sns_topic_arn         = module.error_alerts_sns.topic_arn
  slack_webhook_url     = var.slack_webhook_url  # Optional: Add Slack webhook URL
  region                = "eu-central-1"
  log_group_arn_pattern = "arn:aws:logs:eu-central-1:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"
  
  tags = {
    Name        = "error-processor"
    Environment = "dev"
  }
}

# CloudWatch Log Subscriptions for each Lambda function
module "get_all_authors_error_subscription" {
  source = "./modules/cloudwatch-subscription"
  
  lambda_function_name  = "get-all-authors"
  log_group_name        = "/aws/lambda/get-all-authors"
  filter_pattern        = "?ERROR ?CRITICAL ?5xx"
  destination_lambda_arn = module.error_processor_lambda.lambda_function_arn
  lambda_permission_id   = module.error_processor_lambda.lambda_function_name
}

module "get_all_courses_error_subscription" {
  source = "./modules/cloudwatch-subscription"
  
  lambda_function_name  = "get-all-courses"
  log_group_name        = "/aws/lambda/get-all-courses"
  filter_pattern        = "?ERROR ?CRITICAL ?5xx"
  destination_lambda_arn = module.error_processor_lambda.lambda_function_arn
  lambda_permission_id   = module.error_processor_lambda.lambda_function_name
}

module "get_course_error_subscription" {
  source = "./modules/cloudwatch-subscription"
  
  lambda_function_name  = "get-course"
  log_group_name        = "/aws/lambda/get-course"
  filter_pattern        = "?ERROR ?CRITICAL ?5xx"
  destination_lambda_arn = module.error_processor_lambda.lambda_function_arn
  lambda_permission_id   = module.error_processor_lambda.lambda_function_name
}

module "save_course_error_subscription" {
  source = "./modules/cloudwatch-subscription"
  
  lambda_function_name  = "save-course"
  log_group_name        = "/aws/lambda/save-course"
  filter_pattern        = "?ERROR ?CRITICAL ?5xx"
  destination_lambda_arn = module.error_processor_lambda.lambda_function_arn
  lambda_permission_id   = module.error_processor_lambda.lambda_function_name
}

module "update_course_error_subscription" {
  source = "./modules/cloudwatch-subscription"
  
  lambda_function_name  = "update-course"
  log_group_name        = "/aws/lambda/update-course"
  filter_pattern        = "?ERROR ?CRITICAL ?5xx"
  destination_lambda_arn = module.error_processor_lambda.lambda_function_arn
  lambda_permission_id   = module.error_processor_lambda.lambda_function_name
}

module "delete_course_error_subscription" {
  source = "./modules/cloudwatch-subscription"
  
  lambda_function_name  = "delete-course"
  log_group_name        = "/aws/lambda/delete-course"
  filter_pattern        = "?ERROR ?CRITICAL ?5xx"
  destination_lambda_arn = module.error_processor_lambda.lambda_function_arn
  lambda_permission_id   = module.error_processor_lambda.lambda_function_name
}
