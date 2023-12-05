
variable "aws_account" {
  description = "AWS account ID"
  type        = string
  default     = "286514997612"
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-2"
}

variable "external_secrets_asm_resource" {
  type    = string
  default = "eks-int-sandbox-b-*"
}

variable "project_name" {
  type    = string
  default = "sandbox"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "sandbox"
}