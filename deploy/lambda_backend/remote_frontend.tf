data "terraform_remote_state" "frontend" {
  backend = "s3"
  config = {
    key="terraform/spikes/simple-full-stack/terraform.tfstate"
    region=var.STATE_REGION
    bucket=var.STATE_BUCKET
  }
}

locals {
  frontend_base_url = data.terraform_remote_state.frontend.outputs.frontend_base_url
}
