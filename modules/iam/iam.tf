locals {
  project_name = var.project_name

}
resource "aws_iam_role" "roles" {
  name = "${local.project_name}-iamanywhere-trust-role"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "rolesanywhere.amazonaws.com",
        },
        Action = [
          "sts:AssumeRole",
          "sts:TagSession",
          "sts:SetSourceIdentity"
        ],
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = "arn:aws:rolesanywhere:${var.region}:${var.aws_account}:trust-anchor/${aws_rolesanywhere_trust_anchor.trust_anchor.id}"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "asm_full_access" {
  name        = "${local.project_name}-secret-manager-access"
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

resource "aws_iam_role_policy_attachment" "roles_asm_access" {
  role       = aws_iam_role.roles.name
  policy_arn = aws_iam_policy.asm_full_access.arn
}