output "s3_bucket_name" {
  value = aws_s3_bucket.site.id
}

output "cloudfront_domain" {
  value = aws_cloudfront_distribution.cdn.domain_name
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.cdn.id
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}
