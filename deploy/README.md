# about
- api-gateway-s3-eb: An api gateway facade to an s3 deployment, and an elastic beanstalk backend

# terraform
terraform is used for each deployment.

```sh
#defines AWS_ACCESS_KEY_ID,AWS_SECRET_ACCESS_KEY,AWS_DEFAULT_REGION or AWS_PROFILE
#defines TF_VAR_STATE_BUCKET, TF_VAR_STATE_DYNAMO_DB_TABLE, TF_VAR_STATE_REGION
. ~/.aws/terraform_keys__stelios

#terraform init (only the first time)
terraform init \
  -backend-config=./backend.auto.tfvars \
  -backend-config="bucket=${TF_VAR_STATE_BUCKET:?}" \
  -backend-config="region=${TF_VAR_STATE_REGION:?}" \
  -backend-config="dynamodb_table=${TF_VAR_STATE_DYNAMO_DB_TABLE:?}"
```

# api gateway api_gw_logging
see https://www.rockedscience.net/articles/api-gateway-logging-with-terraform/
and see https://www.terraform.io/docs/providers/aws/r/api_gateway_account.html

for enabling gw logging
