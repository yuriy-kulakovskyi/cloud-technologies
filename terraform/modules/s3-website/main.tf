# S3 Bucket for static website hosting
resource "aws_s3_bucket" "website" {
  bucket = var.bucket_name
  
  tags = merge(
    var.tags,
    {
      Name = var.bucket_name
      Purpose = "Static Website Hosting"
    }
  )
}

# S3 Bucket Website Configuration
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# S3 Bucket Public Access Block Configuration
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# S3 Bucket Policy for public read access
resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  depends_on = [aws_s3_bucket_public_access_block.website]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website.arn}/*"
      },
      {
        Sid       = "CloudFrontReadGetObject"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })
}

# Upload index.html
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.website.id
  key          = "index.html"
  source       = "${var.build_directory}/index.html"
  content_type = "text/html"
  etag         = filemd5("${var.build_directory}/index.html")

  depends_on = [aws_s3_bucket_policy.website]
}

# Upload manifest.json
resource "aws_s3_object" "manifest" {
  bucket       = aws_s3_bucket.website.id
  key          = "manifest.json"
  source       = "${var.build_directory}/manifest.json"
  content_type = "application/json"
  etag         = filemd5("${var.build_directory}/manifest.json")

  depends_on = [aws_s3_bucket_policy.website]
}

# Upload favicon.ico
resource "aws_s3_object" "favicon" {
  bucket       = aws_s3_bucket.website.id
  key          = "favicon.ico"
  source       = "${var.build_directory}/favicon.ico"
  content_type = "image/x-icon"
  etag         = filemd5("${var.build_directory}/favicon.ico")

  depends_on = [aws_s3_bucket_policy.website]
}

# Upload asset-manifest.json
resource "aws_s3_object" "asset_manifest" {
  bucket       = aws_s3_bucket.website.id
  key          = "asset-manifest.json"
  source       = "${var.build_directory}/asset-manifest.json"
  content_type = "application/json"
  etag         = filemd5("${var.build_directory}/asset-manifest.json")

  depends_on = [aws_s3_bucket_policy.website]
}

# Upload all files from static directory
resource "aws_s3_object" "static_files" {
  for_each = fileset("${var.build_directory}/static", "**/*")

  bucket = aws_s3_bucket.website.id
  key    = "static/${each.value}"
  source = "${var.build_directory}/static/${each.value}"
  
  content_type = lookup(
    {
      "js"  = "application/javascript"
      "css" = "text/css"
      "map" = "application/json"
      "txt" = "text/plain"
    },
    split(".", each.value)[length(split(".", each.value)) - 1],
    "application/octet-stream"
  )
  
  etag = filemd5("${var.build_directory}/static/${each.value}")

  depends_on = [aws_s3_bucket_policy.website]
}
