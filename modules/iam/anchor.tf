resource "aws_rolesanywhere_trust_anchor" "trust_anchor" {
  name    = "${local.project_name}-trust_anchor"
  enabled = true
  source {
    source_data {
      acm_pca_arn = aws_acmpca_certificate_authority.roles.arn
    }
    source_type = "AWS_ACM_PCA"
  }
  # Wait for the ACMPCA to be ready to receive requests before setting up the trust anchor
  depends_on = [aws_acmpca_certificate.example]
}

resource "aws_rolesanywhere_profile" "profile" {
  enabled   = true
  name      = "${local.project_name}-profile"
  role_arns = [aws_iam_role.roles.arn]
  managed_policy_arns  = [aws_iam_policy.profile_managed_policies.arn]
}

resource "aws_iam_policy" "profile_managed_policies" {
  name        = "${local.project_name}-user-profile-policies"
  path        = "/"
  description = "Allows access to ASM"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecretVersionIds"
      ]
      Resource = [
         "arn:aws:secretsmanager:${var.region}:${var.aws_account}:secret:${var.external_secrets_asm_resource}"
      ]
      Effect = "Allow"
    }]
  })
}
