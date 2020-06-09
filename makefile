.PHONY: deploy clean help build apigw-deploy cf-eb-deploy cf-deploy cf-lambda-deploy
.DEFAULT: help
## see https://devhints.io/makefile
## see https://gist.github.com/prwhite/8168133
help:     ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'
	@echo define SKIP_INIT to avoid repeated init during development
TERRAFORM=terraform

ifeq ($(SKIP_INIT),)
#$(call tf_init,directory)
define tf_init
	cd $(1) && $(TERRAFORM) init \
	-backend-config=./backend.auto.tfvars \
	-backend-config="bucket=$${TF_VAR_STATE_BUCKET:?}" \
	-backend-config="region=$${TF_VAR_STATE_REGION:?}" \
	-backend-config="dynamodb_table=$${TF_VAR_STATE_DYNAMO_DB_TABLE:?}"
endef
else
define tf_init
endef
endif

#$(call tf_create,directory)
define tf_apply
	cd $(1) && $(TERRAFORM) apply -auto-approve
endef

#$(call tf_apply,directory)
define tf_plan
	cd $(1) && $(TERRAFORM) plan
endef

#$(call tf_apply,directory)
define tf_destroy
	cd $(1) && $(TERRAFORM) destroy -auto-approve
endef

#$(call tf_apply,directory)
define tf_output
	cd $(1) && $(TERRAFORM) output
endef

cf-lambda: ## deploy cloudfront and lambda with code
	$(call tf_init,deploy/cloudfront)
	$(call tf_init,deploy/lambda_backend)
	$(call tf_apply,deploy/cloudfront)
	$(call tf_apply,deploy/lambda_backend)
	cd src/frontend && $(MAKE) cf-lambda-deploy
	cd src/backend && $(MAKE) lambda_deploy
	cd deploy/cloudfront && $(TERRAFORM) output frontend_base_url

cf-lambda-plan: ## plan cloudfront and lambda with code
	$(call tf_init,deploy/cloudfront)
	$(call tf_init,deploy/lambda_backend)
	$(call tf_plan,deploy/cloudfront)
	$(call tf_plan,deploy/lambda_backend)

cf-beanstalk-plan: ## plan cloudfront and beanstalk
	$(call tf_init,deploy/cloudfront)
	$(call tf_init,deploy/eb_backend)
	$(call tf_plan,deploy/cloudfront)
	$(call tf_plan,deploy/eb_backend)

destroy: ## destroy fronetend and backend deployments
	$(call tf_init,deploy/cloudfront)
	$(call tf_init,deploy/lambda_backend)
	$(call tf_destroy,deploy/lambda_backend)
	$(call tf_destroy,deploy/cloudfront)

output: ## outputs for the fronetend and backend deployments
	$(call tf_init,deploy/cloudfront)
	$(call tf_init,deploy/lambda_backend)
	$(call tf_output,deploy/cloudfront)
	$(call tf_output,deploy/lambda_backend)
