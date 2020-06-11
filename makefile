.PHONY: deploy clean help build apigw-deploy cf-eb-deploy cf-deploy cf-lambda-deploy
.DEFAULT: help
# see https://devhints.io/makefile
# see https://gist.github.com/prwhite/8168133
help:     ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'|sort
	@echo     define SKIP_INIT to avoid repeated init during development
	@echo     define SNS_ARN to get sns notifications
TERRAFORM=terraform

#export variables to sub makes
export

#set to empty for non silent
SILENT=@

ifeq ($(SNS_ARN),)
define notify
true
endef
else
define notify
aws sns publish --topic-arn $(SNS_ARN) --message "$(1)"
endef
endif

ifeq ($(SKIP_INIT),)
#$(call tf_init,directory)
define tf_init
	$(SILENT) echo init $(1) && cd $(1) && $(TERRAFORM) init \
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
	$(SILENT) echo apply $(1) && cd $(1) && $(TERRAFORM) apply -auto-approve
endef

define tf_apply2
	$(SILENT) echo apply $(1) && cd $(1) && ($(TERRAFORM) apply -auto-approve || $(TERRAFORM) apply -auto-approve)
endef

#$(call tf_apply,directory)
define tf_plan
	$(SILENT) echo plan $(1) && cd $(1) && $(TERRAFORM) plan
endef

#$(call tf_apply,directory)
define tf_destroy
	$(SILENT) echo destroy $(1) && cd $(1) && $(TERRAFORM) destroy -auto-approve
endef

#$(call tf_apply,directory)
define tf_output
	$(SILENT) echo output $(1) && cd $(1) && $(TERRAFORM) output
endef

BUILD_ID:=$(shell git remote get-url origin) $(shell git rev-parse --short HEAD)

cf-lambda: ## deploy cloudfront and lambda with code
	$(SILENT) $(call notify,build started running cf-lambda $(BUILD_ID))
	$(SILENT) $(MAKE) cf-lambda-wrapped || ( $(call notify,build failed $(BUILD_ID)) && false )
	$(eval BASE_URL:=$(shell cd deploy/cloudfront && $(TERRAFORM) output frontend_base_url))
	$(SILENT) $(call notify,build sucess $(BUILD_ID) available at $(BASE_URL))
	$(SILENT) echo available at $(BASE_URL)

cf-lambda-wrapped:
	$(call tf_init,deploy/cloudfront)
	$(call tf_init,deploy/lambda_backend)
	$(call tf_apply,deploy/cloudfront)
	$(call tf_apply,deploy/lambda_backend)
	$(SILENT) cd src/frontend && $(MAKE) cf-lambda-deploy
	$(SILENT) cd src/backend && $(MAKE) lambda_deploy

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

cf-beanstalk: ## create cloudfront and beanstalk
	$(SILENT) $(call notify,cf-beanstalk started $(BUILD_ID))
	$(SILENT) $(MAKE) cf-beanstalk-wrapped || ( $(call notify,cf-beanstalk failed $(BUILD_ID)) && false )
	$(eval BASE_URL:=$(shell cd deploy/cloudfront && $(TERRAFORM) output frontend_base_url))
	$(SILENT) $(call notify,cf-beanstalk sucess $(BUILD_ID) available at $(BASE_URL))
	$(SILENT) echo available at $(BASE_URL)


cf-beanstalk-wrapped:
		$(call tf_init,deploy/cloudfront)
		$(call tf_init,deploy/eb_backend)
		$(call tf_apply,deploy/cloudfront)
		@#apply twice becasue of tf? bug
		$(call tf_apply2,deploy/eb_backend)
		$(SILENT) cd src/frontend && $(MAKE) cf-eb-deploy
		$(SILENT) cd src/backend && $(MAKE) ebbackend_deploy


destroy: ## destroy fronetend and backend deployments
	$(SILENT) $(call notify,destroy started $(BUILD_ID))
	$(SILENT) $(MAKE) destroy-wrapped || ( $(call notify,destroy failed $(BUILD_ID)) && false )
	$(SILENT) $(call notify,destroy success $(BUILD_ID))

destroy-wrapped:
	$(call tf_init,deploy/cloudfront)
	$(call tf_init,deploy/lambda_backend) #all backends point to the same key so destroying any of them applies to all
	$(call tf_destroy,deploy/lambda_backend) #backend depends on frontend so reverse order of destruction
	$(call tf_destroy,deploy/cloudfront)

cf-output: ## outputs for the cf frontend and any backend deployment
	$(call tf_init,deploy/cloudfront)
	$(call tf_init,deploy/lambda_backend)
	$(call tf_output,deploy/cloudfront)
	$(call tf_output,deploy/lambda_backend)
