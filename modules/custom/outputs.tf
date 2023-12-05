output "anchor" {
  value = aws_rolesanywhere_trust_anchor.trust_anchor.arn
}

output "profile" {
  value = aws_rolesanywhere_profile.profile.arn
}

output "awsiam" {
  value = aws_iam_role.roles.arn
}


# data "template_file" "arns" {
#   template = "${aws_rolesanywhere_trust_anchor.trust_anchor.arn}\n${aws_rolesanywhere_profile.profile.arn}\n${aws_iam_role.roles.arn}"

#   vars = {
#     trust_anchor_arn = aws_rolesanywhere_trust_anchor.trust_anchor.arn
#     profile_arn      = aws_rolesanywhere_profile.profile.arn
#     role_arn         = aws_iam_role.roles.arn
#   }
# }


# resource "local_file" "output_arn" {
#   content  = data.template_file.arns.rendered
#   filename = "./output.txt"
# }

data "template_file" "aws_export_profile" {
  template = <<-EOT
[profile iam_anywhere]
region=us-east-2
credential_process = aws_signing_helper credential-process --trust-anchor-arn ${aws_rolesanywhere_trust_anchor.trust_anchor.arn} --profile-arn ${aws_rolesanywhere_profile.profile.arn} --role-arn ${aws_iam_role.roles.arn} --certificate /path/client.pem --private-key /path/client.key
EOT
  vars = {
    trust_anchor_arn = aws_rolesanywhere_trust_anchor.trust_anchor.arn
    profile_arn      = aws_rolesanywhere_profile.profile.arn
    role_arn         = aws_iam_role.roles.arn
  }
}

resource "local_file" "aws_export_profile" {
  content  = data.template_file.aws_export_profile.rendered
  filename = "./aws-config.txt"
}