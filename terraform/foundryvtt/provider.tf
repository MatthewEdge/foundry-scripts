terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.74.3"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      App = "FoundryVTT"
    }
  }
}
