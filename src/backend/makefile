.PHONY: deploy build clean help ebdeploy_non_block waitGood
.DEFAULT: help
## see https://devhints.io/makefile
## see https://gist.github.com/prwhite/8168133
help:     ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

clean:    ## cleanup temporary files
	mvn clean

build: target   ## prod build

target:
	mvn clean package

SHELL=/bin/bash

WAIT_FOR_HEALTY= aws elasticbeanstalk describe-environment-health --environment-name tf-test-env-name --attribute-names Status
WAIT_TIMEOUT_SECONDS=300

waitGood: ## wait for the environment to go to good state
waitGood_secondTime:

waitGood waitGood_secondTime:
	test -n "$(ENV)" # test ENV
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

TF_DEPLOY_DIR:=../../deploy/api-gateway-s3-eb
BUCKET_PATH:=eb_uploads/app-$(VERSION).jar
VERSION:=$(shell echo $$(date +%Y%m%d-%H%M)-$$(git rev-parse --verify --short HEAD))
APP:=$(shell (cd $(TF_DEPLOY_DIR) && terraform output backend_eb_app))
ENV:=$(shell (cd $(TF_DEPLOY_DIR) && terraform output backend_eb_env))
BUCKET:=$(shell (cd $(TF_DEPLOY_DIR) && terraform output backend_eb_bucket))

ebmakeVersion: build ## upload a version variables: VERSION
	test -n "$(BUCKET)" #BUCKET
	test -n "$(APP)" #APP
	test -n "$(ENV)" #ENV
	aws s3 cp target/*.jar s3://$(BUCKET)/$(BUCKET_PATH)
	aws elasticbeanstalk create-application-version --application-name $(APP) --version-label $(VERSION) --source-bundle S3Bucket="$(BUCKET)",S3Key="$(BUCKET_PATH)"

ebdeploy_non_block:   ## deploy stage in elastic beanstalk without blocking. vars: VERSION
ebdeploy_non_block: build ebmakeVersion
	test -n "$(VERSION)" #VERSION
	test -n "$(APP)" #APP
	test -n "$(ENV)" #ENV
	aws elasticbeanstalk update-environment --application-name $(APP) --environment-name $(ENV) --version-label $(VERSION)
	@echo version=$(VERSION)

ebdeploy:   ## deploy stage in elastiv beanstalk vars: VERSION
ebdeploy: waitGood ebdeploy_non_block waitGood_secondTime
