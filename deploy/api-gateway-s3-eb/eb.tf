resource "aws_elastic_beanstalk_application" "tftest" {
  name        = "tf-test-name"
  description = "tf-test-desc"
/*
  appversion_lifecycle {
    service_role          = "${aws_iam_role.beanstalk_service.arn}"
    max_count             = 128
    delete_source_from_s3 = true
  }
*/
  tags = merge(
    local.common_tags
  )

}
/*
resource "aws_elastic_beanstalk_configuration_template" "tf_template" {
  name                = "tf-test-template-config"
  application         = "${aws_elastic_beanstalk_application.tftest.name}"
  solution_stack_name = "64bit Amazon Linux 2 v3.0.0 running Corretto 11"

  tags = merge(
    local.common_tags
  )
}*/

locals {
  #namespace=>name=>value
  ebConfig = {
    "aws:autoscaling:asg" = {
      "Availability Zones" = "Any 2"
      "MinSize" = "1"
      "MaxSize" = "1"
    }
    "aws:ec2:instances"={
      "InstanceTypes" = "t3.nano,t3a.nano"
    }
    "aws:ec2:vpc" = {
      "AssociatePublicIpAddress" = false
    }
  }

  ebConfigFlat = flatten([
    for ns,props in local.ebConfig: [
      for name, value in props : {
        namespace=ns
        name=name
        value=value
      }
    ]
  ])
}

resource "aws_elastic_beanstalk_environment" "tfenvtest" {
  name                = "tf-test-name"
  application         = aws_elastic_beanstalk_application.tftest.name
  solution_stack_name = "64bit Amazon Linux 2 v3.0.0 running Corretto 11"

  tags = merge(
    local.common_tags
  )

  #see https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/beanstalk-environment-configuration-advanced.html

  dynamic "setting" {
    for_each = local.ebConfigFlat
    content {
      namespace = setting.value["namespace"]
      name = setting.value["name"]
      value = setting.value["value"]
    }
  }
}
