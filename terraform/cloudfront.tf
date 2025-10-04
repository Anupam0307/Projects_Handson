# Origin Access Control (OAC) - lets CloudFront sign requests to S3 (recommended over OAI)
resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "${var.domain_name}-oac"
  description                       = "OAC for CloudFront -> S3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
  origin_access_control_origin_type = "s3"
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled = true
  aliases = ["www.${var.domain_name}"]

 origin {
  origin_id   = "s3-${aws_s3_bucket.site.id}"
  domain_name = aws_s3_bucket.site.bucket_regional_domain_name

  origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
}


  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-${aws_s3_bucket.site.id}"

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  price_class = "PriceClass_100" # adjust to your traffic/region needs

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  # Typical SPA handling: return index.html for 403/404 so front-end routing works
  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }
}
