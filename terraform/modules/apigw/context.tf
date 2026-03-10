# Context configuration for API Gateway module
# This file can contain common variables and locals used across the module

locals {
  common_tags = merge(
    var.tags,
    {
      Module = "apigw"
      ManagedBy = "Terraform"
    }
  )
}
