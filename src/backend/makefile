.PHONY: deploy build clean help ebdeploy_non_block waitGood EB_TF_VARS ebbackend_deploy ebapigw_deploy ebdeploy
.DEFAULT: help
## see https://devhints.io/makefile
## see https://gist.github.com/prwhite/8168133
help:     ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

clean:    ## cleanup temporary files
	./mvnw clean

build: ## prod build
build: target

target:
	./mvnw clean package

SHELL=/bin/bash

WAIT_TIMEOUT_SECONDS=300

waitGood: ## wait for the environment to go to good state
waitGood_secondTime:

waitGood waitGood_secondTime: EB_TF_VARS
	@set -o pipefail; \
	while true; \
		do \
			state=$$(aws elasticbeanstalk describe-environment-health --environment-name $(ENV) --attribute-names Status \
			| jq -r .Status); \
			echo $$(date --rfc-3339=seconds) "checking for $$SECONDS sec env=$(ENV) state=$$state" ; \
			[[ "$$state" == "Ready" ]] && exit 0; \
			[[ $$SECONDS -gt $(WAIT_TIMEOUT_SECONDS) ]] && echo timed out waiting >/dev/stderr && exit 1; \
			sleep 10; \
		done;

EB_BUCKET_PATH:=eb_uploads/app-$(VERSION).jar
VERSION:=$(shell echo $$(date +%Y%m%d-%H%M)-$$(git rev-parse --verify --short HEAD))

EB_TF_VARS:
	$(eval APP=$(shell (cd $(TF_DEPLOY_DIR) && terraform output backend_eb_app)))
	test -n "$(APP)" #APP
	$(eval ENV=$(shell (cd $(TF_DEPLOY_DIR) && terraform output backend_eb_env)))
	test -n "$(ENV)" #ENV
	$(eval BUCKET=$(shell (cd $(TF_DEPLOY_DIR) && terraform output backend_eb_bucket)))
	test -n "$(BUCKET)" #BUCKET

ebmakeVersion: build ## upload a version variables: VERSION
	test -n "$(VERSION)" #VERSION
	aws s3 cp app/target/*.jar s3://$(BUCKET)/$(EB_BUCKET_PATH)
	aws elasticbeanstalk create-application-version --application-name $(APP) --version-label $(VERSION) --source-bundle S3Bucket="$(BUCKET)",S3Key="$(EB_BUCKET_PATH)"

ebdeploy_non_block:   ## deploy stage in elastic beanstalk without blocking. vars: VERSION
ebdeploy_non_block: EB_TF_VARS build ebmakeVersion
	test -n "$(VERSION)" #VERSION
	aws elasticbeanstalk update-environment --application-name $(APP) --environment-name $(ENV) --version-label $(VERSION)
	@echo version=$(VERSION)


ebdeploy: waitGood ebdeploy_non_block waitGood_secondTime

ebapigw_deploy: ## deploy stage in elastic beanstalk vars: VERSION TF_DEPLOY_DIR
ebapigw_deploy: TF_DEPLOY_DIR:=../../deploy/api-gateway-s3-eb
ebapigw_deploy: ebdeploy

ebbackend_deploy: ## shorthand for ebdeploy TF_DEPLOY_DIR=../../deploy/eb_backend
ebbackend_deploy: TF_DEPLOY_DIR=../../deploy/eb_backend
ebbackend_deploy: ebdeploy
