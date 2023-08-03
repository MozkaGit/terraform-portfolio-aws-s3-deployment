provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["$HOME/.aws/credentials"]
}

terraform {
  backend "s3" {
    bucket                  = "terraform-backend-mozka"
    key                     = "website.tfstate"
    region                  = "us-east-1"
    shared_credentials_file = "$HOME/.aws/credentials"
  }
}