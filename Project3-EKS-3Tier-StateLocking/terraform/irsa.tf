module "irsa_secrets" {
  source = "./modules/iam-irsa"

  role_name = "eks-secrets-reader"

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["default:app-sa"]
    }
  }

  policy_arn = aws_iam_policy.secrets_access.arn
}
