terraform {
  backend "s3" {
    bucket = "sev-kops-terraform-state"
    region = "eu-west-1"
    key = "state"
  }
}
