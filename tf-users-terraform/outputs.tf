output "trust_anchor_arn" {
  value = aws_rolesanywhere_trust_anchor.trust_anchor.arn
}

output "profile_arn" {
  value = aws_rolesanywhere_profile.profile.arn
}

output "role_arn" {
  value = aws_iam_role.roles.arn
}

data "template_file" "aws_export_profile" {
  template = <<-EOT
TRUST_ANCHOR_ARN:${aws_rolesanywhere_trust_anchor.trust_anchor.arn}
PROFILE_ARN:${aws_rolesanywhere_profile.profile.arn}
ROLE_ARN:${aws_iam_role.roles.arn}
EOT
  vars = {
    trust_anchor_arn = aws_rolesanywhere_trust_anchor.trust_anchor.arn
    profile_arn      = aws_rolesanywhere_profile.profile.arn
    role_arn         = aws_iam_role.roles.arn
  }
}

resource "local_file" "aws_export_profile" {
  content  = data.template_file.aws_export_profile.rendered
  filename = "./ARNs.yaml"
}