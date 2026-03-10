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

# Create a VPC resource
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "example-vpc"
  }
}

# Create a DynamoDB table using the module
module "dynamodb_table" {
  source = "./modules/dynamodb"
  
  table_name   = "example-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  
  attributes = [
    {
      name = "id"
      type = "S"
    }
  ]
  
  tags = {
    Name        = "example-dynamodb-table"
    Environment = "dev"
  }
}
