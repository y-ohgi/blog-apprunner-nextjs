REPOSITORY_URL := 855200245635.dkr.ecr.ap-northeast-1.amazonaws.com/app-next
APPRUNNER_ARN  := arn:aws:apprunner:ap-northeast-1:855200245635:service/app-next/b7195e9985834e579a423337ad3d644a

CMD_TERRAFORM = docker run \
	-v $(HOME)/.aws/:/root/.aws:ro \
	-v `pwd`:/app \
	-w /app/infra \
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
