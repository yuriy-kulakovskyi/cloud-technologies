# Labels and naming conventions for API Gateway resources

locals {
  # Resource naming
  api_name_prefix = var.api_name
  
  # Stage configuration
  stage_settings = {
    metrics_enabled    = true
    logging_level      = "INFO"
    data_trace_enabled = true
  }
}
