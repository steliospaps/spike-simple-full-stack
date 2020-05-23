# about
an api gw pointing to a lambda.
Options enforce cors
# terraform apply
if cors or other apigw related setting change, the the
```bash
terraform taint module.stage.aws_api_gateway_deployment.default
terraform apply
```
