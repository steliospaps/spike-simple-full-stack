terraform {
  backend "s3" {
    # comes from environment bucket = ""
    encrypt = true
  }
}
