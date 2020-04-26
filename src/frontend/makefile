.PHONY: deploy build clean help
.DEFAULT: help
## see https://devhints.io/makefile
## see https://gist.github.com/prwhite/8168133
help:     ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'
clean:    ## cleanup temporary files
	@rm -rf build

build:    ## prod build
	npm run build

TF_DEPLOY_DIR=../../deploy/api-gateway-s3-eb

deploy:   ## deploy stage (default test)
deploy: build
	$(eval BUCKET=$(shell (cd $(TF_DEPLOY_DIR) && terraform output frontend_bucket)))
	test -n "$(BUCKET)" #fail fast if the state is not there
	aws s3 sync --delete build/ s3://$(BUCKET)
	@echo '*******************'
	@echo available at $$(cd $(TF_DEPLOY_DIR) && terraform output frontend_base_url)/index.html
