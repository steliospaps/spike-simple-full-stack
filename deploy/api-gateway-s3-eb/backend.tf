terraform {
  backend "s3" {
    # comes from environment bucket = ""
    key    = "terraform/spikes/simple-full-stack/terraform.tfstate"
    encrypt = true
  }
}
