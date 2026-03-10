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
