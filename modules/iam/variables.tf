variable "aws_account" {
  description = "AWS account ID"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "organization" {
  type = string
}

variable "organizational_unit" {
  type = string
}

variable "common_name" {
  type = string
}

variable "external_secrets_asm_resource" {
  type = string
}

variable "project_name" {
  type = string
}