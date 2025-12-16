resource "aws_s3_bucket" "site" {
  bucket = replace(lower(var.domain_name), ".", "-")

  tags = {
    Name = "static-site-${var.domain_name}"
    Env  = "prod"
  }
}

# Enforce bucket owner ownership (no ACLs needed)
resource "aws_s3_bucket_ownership_controls" "site" {
  bucket = aws_s3_bucket.site.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
