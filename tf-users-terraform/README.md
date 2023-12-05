# Roles-Anywhere

This repository contains terraform steps and data required to configure Roles-Anywhere access to get access to AWS services based on IAM Policies

## Current allow services via Iam-policy

- `AWS Secret-Manager`

## Initial steps

1. Navigate to `main.tf` file and update variables defaults based on your requirement

```YAML
 aws_account                   = "286514997612"
 environment                   = "sandbox-b"
 external_secrets_asm_resource = "eks-int-sandbox-b-*"
 region                        = "us-east-1"
 project_name                  = "sandbox"
```
Note: The name use in `external_secrets_asm_resource` is going to be use in the policy to get access from Iam-anywhere

2. Run `script.sh` to generate new CA.pem, client-key and client.pem certificates that get save inside `/certificates` folder.


# Install terraform

## OSX
`brew install hashicorp/tap/terraform`

## Windows
`choco install terraform`

## Linux
`sudo apt-get install terraform`

## Terraform steps

1. Run `terraform init -reconfigure -upgrade` command.
2. Run `terraform apply` and Enter a value:`yes`.

Note: The above run would generate 3 `ARNs` important for futher steps and they are saved to file `ARNs.yaml` after running `terraform apply`
e.g
```YAML
  TRUST_ANCHOR_ARN: arn:aws:rolesanywhere:us-east-1:286514xxxx:trust-anchor/0193dda9-5c0a-4086-a168-2b1d6xxxxx
  PROFILE_ARN: arn:aws:rolesanywhere:us-east-1:286514xxxx:profile/8e04a976-8ed1-473c-95c3-40b75a4xxxxxx
  ROLE_ARN: arn:aws:iam::286514xxxx:role/sandbox-iamanywhere-trust-role
```
3. Finally apply to `Kubernetes` the manifest `k8s-secrets.yaml` created after the terraform run using `kubectl apply -f k8s-secrets.yaml`

## AWS Resources:
After running Terraform this would create the AWS resources below with prefix used in the `project_name variable`.

- `IAM Role`          = ${project_name}-iamanywhere-trust-role

- `Trust Anchor`      = ${project_name}-trust_anchor

- `Trust Role Policy` = ${project_name}-iamanywhere-trust-role-policies

- `Profile`           = ${project_name}-profile

- `IAM Policy`        = ${project_name}-user-profile-policies

## Terraform Outputs:

- `ARNs.yaml`
- `k8s-secrets.yaml`