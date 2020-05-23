.PHONY: deploy clean help build apigw-deploy cf-eb-deploy cf-deploy cf-lambda-deploy
.DEFAULT: help
## see https://devhints.io/makefile
## see https://gist.github.com/prwhite/8168133
help:     ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'
clean:    ## cleanup temporary files
	@rm -rf build

node_modules:
	npm install

PUBLIC_URL=$(shell cd $(TF_FRONT_DEPLOY_DIR) && terraform output frontend_base_url)
BUCKET=$(shell (cd $(TF_FRONT_DEPLOY_DIR) && terraform output frontend_bucket))
BACKEND=$(shell (cd $(TF_BACK_DEPLOY_DIR) && terraform output backend_url))

build: node_modules
build:    ## prod build
	test -n "$(BACKEND)" #check BACKEND
	test -n "$(PUBLIC_URL)" #check PUBLIC_URL
	REACT_APP_URL="$(BACKEND)/echo" PUBLIC_URL="$(PUBLIC_URL)" npm run build

deploy: build
	test -n "$(BUCKET)" #fail fast if the state is not there
	aws s3 sync build/ s3://$(BUCKET)
	aws s3 sync --delete build/ s3://$(BUCKET)
	@echo '*******************'
	@echo available at $(PUBLIC_URL)

cf-deploy:
cf-deploy: TF_FRONT_DEPLOY_DIR=../../deploy/cloudfront
cf-deploy: CFID=$(shell (cd $(TF_FRONT_DEPLOY_DIR) && terraform output cf_distribution_id))
cf-deploy: deploy
	aws cloudfront create-invalidation --distribution-id $(CFID) --paths "/index.html"

cf-eb-deploy:   ## deploy in cloudfront
cf-eb-deploy: TF_BACK_DEPLOY_DIR=../../deploy/eb_backend
cf-eb-deploy: cf-deploy

apigw-deploy:   ## deploy stage in api gw
apigw-deploy: deploy
apigw-deploy: TF_FRONT_DEPLOY_DIR=../../deploy/api-gateway-s3-eb
apigw-deploy: TF_BACK_DEPLOY_DIR=../../deploy/api-gateway-s3-eb

cf-lambda-deploy:   ## deploy in cloudfront
cf-lambda-deploy: TF_BACK_DEPLOY_DIR=../../deploy/lambda_backend
cf-lambda-deploy: cf-deploy
