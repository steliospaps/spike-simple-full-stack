output "cname" {
  value = aws_elastic_beanstalk_environment.tfenvtest.cname
}

output "endpoint_url" {
  value= aws_elastic_beanstalk_environment.tfenvtest.endpoint_url
}

output "bucket" {
  value = aws_s3_bucket.eb_code.bucket
}
