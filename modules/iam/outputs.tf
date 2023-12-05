resource "local_file" "cert-body" {
  sensitive_content = aws_acmpca_certificate.example.certificate
  filename          = "./body.pem"
}

resource "local_file" "cert-chain" {
  sensitive_content = aws_acmpca_certificate.example.certificate_chain
  filename          = "./certchain.txt"
}

resource "local_file" "tls_private_key" {
  sensitive_content = tls_private_key.key.private_key_pem
  filename          = "./tls_private_key.pem"
}

output "anchor" {
  value = aws_rolesanywhere_trust_anchor.trust_anchor.arn
}

output "profile" {
  value = aws_rolesanywhere_profile.profile.arn
}

output "awsiam" {
  value = aws_iam_role.roles.arn
}


data "template_file" "example" {
  template = "${aws_rolesanywhere_trust_anchor.trust_anchor.arn}\n${aws_rolesanywhere_profile.profile.arn}\n${aws_iam_role.roles.arn}"

  vars = {
    trust_anchor_arn = aws_rolesanywhere_trust_anchor.trust_anchor.arn
    profile_arn      = aws_rolesanywhere_profile.profile.arn
    role_arn         = aws_iam_role.roles.arn
  }
}


resource "local_file" "output_arn" {
  content  = data.template_file.example.rendered
  filename = "./output.txt"
}