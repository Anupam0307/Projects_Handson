resource "aws_s3_bucket" "site" {
  bucket = replace(lower(var.domain_name), ".", "-") # bucket name must be unique; adjust if needed
  acl    = "private"

  force_destroy = false

  tags = {
    Name = "static-site-${var.domain_name}"
    Env  = "prod"
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Minimal bucket policy allowing the CloudFront OAC to GetObject via canonical user is not used with OAC.
# Policy will be added later via CloudFront origin access control signing (no extra bucket policy needed).
