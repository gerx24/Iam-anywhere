data "template_file" "client_key" {
  template = file("${path.module}/certificates/client.key")
}

data "template_file" "client_pem" {
  template = file("${path.module}/certificates/client.pem")
}

# Creates certificates client.pem/client.key
data "template_file" "secrets" {
  template = <<-EOT
---
apiVersion: v1
kind: Secret
metadata:
  name: rolesanywhere-config
  namespace: external-secrets
stringData:
  TRUST_ANCHOR_ARN: ${aws_rolesanywhere_trust_anchor.trust_anchor.arn}
  PROFILE_ARN: ${aws_rolesanywhere_profile.profile.arn}
  ROLE_ARN: ${aws_rolesanywhere_profile.profile.arn}
---
apiVersion: v1
kind: Secret
metadata:
  name: rolesanywhere-certificate
  namespace: external-secrets
type: kubernetes.io/tls
data:
  tls.crt: ${base64encode(data.template_file.client_pem.rendered)}
  tls.key: ${base64encode(data.template_file.client_key.rendered)}
EOT
  vars = {
    TRUST_ANCHOR_ARN = aws_rolesanywhere_trust_anchor.trust_anchor.arn
    PROFILE_ARN      = aws_rolesanywhere_profile.profile.arn
    ROLE_ARN         = aws_iam_role.roles.arn
  }
}


resource "local_file" "rolesanywhere_secrets" {
  content  = data.template_file.secrets.rendered
  filename = "./k8s-secrets.yaml"
}
