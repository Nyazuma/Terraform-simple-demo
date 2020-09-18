terraform {
  backend "s3" {
    bucket = "nyazuma"
    key    = "terraform.tfstate"
    region = "eu-west-1"
  }
}