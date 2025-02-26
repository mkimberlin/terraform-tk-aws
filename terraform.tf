terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.88"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.7"
    }
  }
}