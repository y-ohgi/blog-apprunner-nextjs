APPRUNNER_ARN  := <YOUR APPRUNNER ARN>
REPOSITORY_URL := $(shell aws ecr describe-repositories --repository-name remix-app --region ap-northeast-1 --query="repositories[0].repositoryUri" --output=text)
TAG            := $(git rev-parse --short HEAD)

CMD_TERRAFORM = docker run \
	-v $(HOME)/.aws/:/root/.aws:ro \
	-v `pwd`:/app \
	-w /app/infra \
	-e TF_VAR_repository_url=$(REPOSITORY_URL) \
	-it \
	hashicorp/terraform:1.0.11

.PHONY: init deploy tf-init

init:
	@more Makefile

deploy:
	docker build -t $(REPOSITORY_URL):$(TAG) .

	aws ecr get-login-password --region ap-northeast-1 \
	| docker login --username AWS --password-stdin $(REPOSITORY_URL) \
	&& docker push $(REPOSITORY_URL):$(TAG)

	aws apprunner update-service \
  --service-arn= $(APPRUNNER_ARN) \
  --source-configuration="`cat infra/apprunner.json | sed \"s/<REPOSITORY_URL>/$(REPOSITORY_URL):$(TAG)/g\"`"

tf-init:
	$(CMD_TERRAFORM) init

tf-plan: tf-init
	$(CMD_TERRAFORM) plan

tf-apply: tf-init
	$(CMD_TERRAFORM) apply

tf-destroy: tf-init
	$(CMD_TERRAFORM) destroy
