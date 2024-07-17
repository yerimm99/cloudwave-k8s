terraform {
  required_version = "1.9.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.4.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
  }
  backend "s3" {
    bucket = "cloudwave-tf-admin20"
    key    = "cwave/terraform.tfstate"
    region = "ap-northeast-2"
  }
}