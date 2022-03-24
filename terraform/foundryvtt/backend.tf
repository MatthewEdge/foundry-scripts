terraform {
  backend "s3" {
    bucket = "medgelabs-foundry"
    key    = "foundry-tfstate"
    region = "us-east-1"
  }
}
