#########################################################################################################
## Terraform configurations (AWS)
#########################################################################################################
#variable "aws_access_key" {
#  type        = string
#  description = "AWS Access Key"
#}
#
#variable "aws_secret_key" {
#  type        = string
#  description = "AWS Secret Key"
#}
#
#variable "aws_session_token" {
#  type        = string
#  description = "AWS Session Token"
#}

variable "pem_location" {
  type    = string
  default = "."
}

variable "terraform_aws_profile" {
  type = string
  default = "cwave"
}

variable "terraform_workspace-name" {
  type = string
  default = "cwave"
}

variable "aws_region" {
  type = string
  default = "ap-northeast-2"
}

#########################################################################################################
## EKS Variable
#########################################################################################################

variable "cluster-name" {
  description = "AWS kubernetes cluster name"
  default     = "cwave"
}

variable "cluster-version" {
  description = "AWS EKS supported Cluster Version to current use"
  default     = "1.29"
}