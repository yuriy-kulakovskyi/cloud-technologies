variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "api_description" {
  description = "Description of the API Gateway"
  type        = string
  default     = "API Gateway for Lambda functions"
}

variable "stage_name" {
  description = "Stage name for API Gateway deployment"
  type        = string
  default     = "prod"
}

variable "get_all_authors_lambda_arn" {
  description = "ARN of the get-all-authors Lambda function"
  type        = string
}

variable "get_all_authors_lambda_invoke_arn" {
  description = "Invoke ARN of the get-all-authors Lambda function"
  type        = string
}

variable "get_all_courses_lambda_arn" {
  description = "ARN of the get-all-courses Lambda function"
  type        = string
}

variable "get_all_courses_lambda_invoke_arn" {
  description = "Invoke ARN of the get-all-courses Lambda function"
  type        = string
}

variable "get_course_lambda_arn" {
  description = "ARN of the get-course Lambda function"
  type        = string
}

variable "get_course_lambda_invoke_arn" {
  description = "Invoke ARN of the get-course Lambda function"
  type        = string
}

variable "save_course_lambda_arn" {
  description = "ARN of the save-course Lambda function"
  type        = string
}

variable "save_course_lambda_invoke_arn" {
  description = "Invoke ARN of the save-course Lambda function"
  type        = string
}

variable "update_course_lambda_arn" {
  description = "ARN of the update-course Lambda function"
  type        = string
}

variable "update_course_lambda_invoke_arn" {
  description = "Invoke ARN of the update-course Lambda function"
  type        = string
}

variable "delete_course_lambda_arn" {
  description = "ARN of the delete-course Lambda function"
  type        = string
}

variable "delete_course_lambda_invoke_arn" {
  description = "Invoke ARN of the delete-course Lambda function"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
