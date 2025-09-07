# 1. Create bucket
resource "aws_s3_bucket" "hosting" {
  bucket = "HostingBucketS3"

  tags = {
    Name = "dev"
    Env  = "Non-Prod"
  }
}

# 2. Website hosting configuration (separate resource now)
resource "aws_s3_bucket_website_configuration" "hosting" {
  bucket = aws_s3_bucket.hosting.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# 3. Bucket policy to allow public access (optional)
resource "aws_s3_bucket_policy" "public_access" {
  bucket = aws_s3_bucket.hosting.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.hosting.arn}/*"
      }
    ]
  })
}
# Upload index.html file
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.hosting.bucket
  key          = "index.html"
  source       = "index.html"
  acl          = "public-read"
  content_type = "text/html"
}
# Upload error.html file
resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.hosting.bucket
  key          = "error.html"
  source       = "error.html"
  acl          = "public-read"
  content_type = "text/html"
}

# 4. Output the website endpoint
output "website_endpoint" {
  value = aws_s3_bucket_website_configuration.hosting.website_endpoint
}
