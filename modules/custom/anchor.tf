resource "null_resource" "script" {
  provisioner "local-exec" {
    command = "bash ${path.module}/script.sh"
  }
}

# Trust anchors
resource "aws_rolesanywhere_trust_anchor" "trust_anchor" {
  name    = "${local.project_name}-trust_anchor"
  enabled = true
  source {
    source_data {
      x509_certificate_data = file("${path.module}/certificates/PrivateCA.pem")
    }
    source_type = "CERTIFICATE_BUNDLE"
  }
}

# Profile
resource "aws_rolesanywhere_profile" "profile" {
  enabled             = true
  name                = "${local.project_name}-profile"
  role_arns           = [aws_iam_role.roles.arn]
  managed_policy_arns = [aws_iam_policy.profile_managed_policies.arn]
}


# Profile policies
#Managed policies limit the permissions granted by the role's permissions policy and are assigned to the role session when the role is assumed.
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
