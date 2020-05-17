resource "aws_elastic_beanstalk_application" "tftest" {
  name        = var.app_name
  description = "tf-test-desc"

  appversion_lifecycle {
    service_role          = aws_iam_role.eb_service.arn
    max_count             = 128
    delete_source_from_s3 = true
  }

  tags = merge(
    local.common_tags
  )

}

resource "aws_s3_bucket_object" "dummy_backend" {
  count = length(var.dummy_app_location) >0 ? 1 : 0
  bucket = aws_s3_bucket.eb_code.bucket
  key    = "beanstalk/dummy_backend.zip"
  source = var.dummy_app_location
  depends_on = [null_resource.module_depends_on]
}

resource "aws_elastic_beanstalk_application_version" "dummy" {
  count = length(var.dummy_app_location) >0 ? 1 : 0
  name        = "dummy"
  application = aws_elastic_beanstalk_application.tftest.name
  description = "dummy backend that reports healthy, and needs no internet connectivity to startup"
  bucket      = aws_s3_bucket.eb_code.bucket
  key         = aws_s3_bucket_object.dummy_backend[0].key
}

resource "aws_iam_role" "eb_service" {
    name = "beanstalk-service-role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "elasticbeanstalk.amazonaws.com"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "elasticbeanstalk"
        }
      }
    }
  ]
}
EOF
  tags = merge(
    local.common_tags
  )
}

resource "aws_iam_policy_attachment" "eb_service" {
    name = "elastic-beanstalk-service"
    roles = [aws_iam_role.eb_service.id]
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService"
}

resource "aws_iam_policy_attachment" "eb_service_health" {
    name = "elastic-beanstalk-service"
    roles = [aws_iam_role.eb_service.id]
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}



# eb_ec2 roles
resource "aws_iam_instance_profile" "eb_ec2" {
  name_prefix = "eb_ec2-"
  role = aws_iam_role.eb_ec2.name
}

resource "aws_iam_role" "eb_ec2" {
  name_prefix = "eb_ec2-"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = merge(
    local.common_tags
  )

}

resource "aws_iam_role_policy_attachment" "eb_ec2" {
  role = aws_iam_role.eb_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}



locals {
  #namespace=>name=>value
  ebConfig = {
    "aws:autoscaling:asg" = {
      # Any, Any 1, Any 2, Any 3
      "Availability Zones" = "Any 2"
      "MinSize" = "1"
      "MaxSize" = "1"
    }
    "aws:autoscaling:launchconfiguration" ={
      "IamInstanceProfile" = aws_iam_instance_profile.eb_ec2.name
      //TODO: make this a conditional property
      "EC2KeyName" = var.key_name
      "SecurityGroups" = aws_security_group.eb_ec2.id
    }
    "aws:ec2:instances"={
      "InstanceTypes" = "t3.nano,t3a.nano,t3.micro,t3a.micro"
    }
    "aws:ec2:vpc" = {
      "VPCId" = local.vpc.id
      "AssociatePublicIpAddress" = false
      "Subnets" = join(",",sort(local.private_subnets.*.id))
      //"AssociatePublicIpAddress" = true
      //"Subnets" = join(",",sort(local.public_subnets.*.id))
      "ELBSubnets" = join(",",sort(local.public_subnets.*.id))
    }
    "aws:elasticbeanstalk:environment" = {
      # LoadBalanced or SingleInstance
      "EnvironmentType" = "LoadBalanced"
      // classic application network
      "LoadBalancerType" = "application"
      "ServiceRole"= aws_iam_role.eb_service.name
    }
    "aws:elasticbeanstalk:healthreporting:system" = {
      // basic enhanced
      "SystemType" = "enhanced"
      // Ok Warning Degraded Severe
      "HealthCheckSuccessThreshold" = "Ok"
    }
    "aws:elbv2:loadbalancer" = {
      "SecurityGroups" = aws_security_group.eb_lb.id
    }
    "aws:elasticbeanstalk:application:environment" = {
      "SERVER_PORT" = "5000"
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

  tags = merge(
    local.common_tags
  )
  name                = var.env_name
  application         = aws_elastic_beanstalk_application.tftest.name
  solution_stack_name = "64bit Amazon Linux 2 v3.0.0 running Corretto 11"

  version_label= length(aws_elastic_beanstalk_application_version.dummy) > 0 ? aws_elastic_beanstalk_application_version.dummy[0].name : null

  #default 20m
  wait_for_ready_timeout="10m"

  #see https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/beanstalk-environment-configuration-advanced.html
  #see https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html
  dynamic "setting" {
    for_each = local.ebConfigFlat
    content {
      namespace = setting.value["namespace"]
      name = setting.value["name"]
      value = setting.value["value"]
    }
  }
}

resource "aws_s3_bucket" "eb_code" {
  bucket_prefix = "eb-code-upload-"

  force_destroy=true

  tags = merge(
    local.common_tags
  )

  lifecycle_rule {
    id      = "daily_cleanup"
    enabled = false
    #staging location for uploads. cleanup daily
    expiration {
      days = 1
    }
  }

}
