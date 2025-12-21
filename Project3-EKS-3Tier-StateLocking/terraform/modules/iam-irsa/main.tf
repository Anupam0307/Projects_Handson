module "this" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-role-for-service-accounts-eks?ref=v5.59.0"

  role_name      = var.role_name
  oidc_providers = var.oidc_providers

  role_policy_arns = {
    secrets = var.policy_arn
  }
}
