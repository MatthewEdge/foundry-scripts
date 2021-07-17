terraform {
  backend "s3" {
    bucket = "medgelabs-foundry-tfstate"
    key    = "foundry-tfstate"
    region = "us-east-1"
  }
}
