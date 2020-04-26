.PHONY: deploy build clean help
.DEFAULT: help
## see https://devhints.io/makefile
## see https://gist.github.com/prwhite/8168133
help:     ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'
clean:    ## cleanup temporary files
	@rm -rf build

build:    ## prod build
	mvn clean package

TF_DEPLOY_DIR=../../deploy/api-gateway-s3-eb
BUCKET_PATH=eb_uploads/app-$(VERSION).jar
VERSION=$(shell echo $$(date +%Y%m%d-%H%M)-$$(git rev-parse --verify --short HEAD))
ebdeploy:   ## deploy stage in elastiv beanstalk vars: VERSION
ebdeploy: build
	$(eval BUCKET=$(shell (cd $(TF_DEPLOY_DIR) && terraform output backend_eb_bucket)))
	@test -n "$(BUCKET)" #fail fast if the state is not there
	$(eval APP=$(shell (cd $(TF_DEPLOY_DIR) && terraform output backend_eb_app)))
	@test -n "$(APP)" #fail fast if the state is not there
	$(eval ENV=$(shell (cd $(TF_DEPLOY_DIR) && terraform output backend_eb_env)))
	@test -n "$(ENV)" #fail fast if the state is not there
	aws s3 cp target/*.jar s3://$(BUCKET)/$(BUCKET_PATH)
	aws elasticbeanstalk create-application-version --application-name $(APP) --version-label $(VERSION) --source-bundle S3Bucket="$(BUCKET)",S3Key="$(BUCKET_PATH)"
	aws elasticbeanstalk update-environment --application-name $(APP) --environment-name $(ENV) --version-label $(VERSION)
	@echo version=$(VERSION)
