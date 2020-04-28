resource "aws_s3_bucket" "frontend" {
  bucket_prefix = "frontend"

  force_destroy=true

  tags = merge(
    local.common_tags
  )
}

resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.frontend.bucket
  key    = "index.html"
  source = "dummy_frontend/index.html"
  content_type="text/html"
  #todo verify this is not updated on tf apply
}
