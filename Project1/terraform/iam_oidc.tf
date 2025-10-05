# GitHub OIDC provider
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [
    # AWS's recommended thumbprint list — terraform/audit may be strict; if AWS updates, you might adjust.
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}

# IAM role that GitHub Actions will assume via OIDC
data "aws_iam_policy_document" "github_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_owner}/${var.github_repo}:ref:refs/heads/${var.github_branch}"]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "${var.github_owner}-${var.github_repo}-github-actions-role"
  assume_role_policy = data.aws_iam_policy_document.github_assume_role.json
}

# Policy granting S3 and CloudFront invalidation permissions limited to this bucket & distribution
data "aws_iam_policy_document" "github_actions_policy" {
  statement {
    sid = "S3Access"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.site.arn
    ]
  }

  statement {
    sid = "S3ObjectAccess"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = [
      "${aws_s3_bucket.site.arn}/*"
    ]
  }

  statement {
    sid = "CloudFrontInvalidation"
    actions = [
      "cloudfront:CreateInvalidation",
      "cloudfront:GetDistribution",
      "cloudfront:GetInvalidation"
    ]
    resources = [
      aws_cloudfront_distribution.cdn.arn
    ]
  }
}

resource "aws_iam_policy" "github_actions" {
  name   = "${var.github_owner}-${var.github_repo}-deploy-policy"
  policy = data.aws_iam_policy_document.github_actions_policy.json
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions.arn
}
