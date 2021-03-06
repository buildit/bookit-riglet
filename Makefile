include .make

export DOMAIN ?= example.tld
export EMAIL ?= user@example.com
export ENV ?= dev
export KEY_NAME ?= ""
export OWNER ?= rig-test-bucket
export PROFILE ?= default
export PROJECT ?= projectname
export REGION ?= us-east-1

export AWS_PROFILE=${PROFILE}
export AWS_REGION=${REGION}


## Create dependency S3 buckets
# Used for storage of Foundation configs, InfraDev storage and Build artifacts
# These are created outside Terraform since it'll store sensitive contents!
# When completely empty, can be destroyed with `make destroy-deps`
deps:
	@./cloudformation/scripts/create-buckets.sh

# Destroy dependency S3 buckets, only destroy if empty
destroy-deps:
	@./cloudformation/scripts/destroy-buckets.sh

# Create dependency ECR repositories
create-repos:
	@./cloudformation/scripts/create-ecr-repos.sh

# Destroy ECR repositories, only destroy if empty
destroy-repos:
	@./cloudformation/scripts/destroy-ecr-repos.sh

## Create IAM user used for building the application
create-build-user:
	@./iam/create-build-user.sh "${OWNER}" "${PROJECT}"

## Creates Foundation and Build

## Creates a new CF stack
create-foundation: upload-foundation
	@aws cloudformation create-stack --stack-name "${OWNER}-${PROJECT}-${ENV}-foundation" \
                --region ${REGION} \
		--template-body "file://cloudformation/foundation/main.yaml" \
		--disable-rollback \
		--capabilities CAPABILITY_NAMED_IAM \
		--parameters \
			"ParameterKey=CidrBlock,ParameterValue=10.1.0.0/16" \
			"ParameterKey=Environment,ParameterValue=${ENV}" \
			"ParameterKey=FoundationBucket,ParameterValue=rig.${OWNER}.${PROJECT}.${ENV}.${REGION}.foundation" \
			"ParameterKey=ProjectName,ParameterValue=${PROJECT}" \
			"ParameterKey=PublicDomainName,ParameterValue=${DOMAIN}" \
			"ParameterKey=Region,ParameterValue=${REGION}" \
			"ParameterKey=SubnetPrivateCidrBlocks,ParameterValue='10.1.11.0/24,10.1.12.0/24,10.1.13.0/24'" \
			"ParameterKey=SubnetPublicCidrBlocks,ParameterValue='10.1.1.0/24,10.1.2.0/24,10.1.3.0/24'" \
		--tags \
			"Key=Email,Value=${EMAIL}" \
			"Key=Environment,Value=${ENV}" \
			"Key=Owner,Value=${OWNER}" \
			"Key=ProjectName,Value=${OWNER}-${PROJECT}-${ENV}"

## Create new CF App stack
create-app: upload-app
	@aws cloudformation create-stack --stack-name "${OWNER}-${PROJECT}-${ENV}-app" \
                --region ${REGION} \
                --disable-rollback \
		--template-body "file://cloudformation/app/main.yaml" \
		--capabilities CAPABILITY_NAMED_IAM \
		--parameters \
			"ParameterKey=AppStackName,ParameterValue=${OWNER}-${PROJECT}-${ENV}" \
			"ParameterKey=BuildArtifactsBucket,ParameterValue=rig.${OWNER}.${PROJECT}.${ENV}.${REGION}.build" \
			"ParameterKey=Environment,ParameterValue=${ENV}" \
			"ParameterKey=FoundationStackName,ParameterValue=${OWNER}-${PROJECT}-${ENV}-foundation" \
			"ParameterKey=InfraDevBucket,ParameterValue=rig.${OWNER}.${PROJECT}.${ENV}.${REGION}.app" \
			"ParameterKey=ProjectName,ParameterValue=${PROJECT}" \
			"ParameterKey=RepositoryName,ParameterValue=${REPO}" \
			"ParameterKey=RepositoryBranch,ParameterValue=${REPO_BRANCH}" \
			"ParameterKey=RepositoryAuthToken,ParameterValue=${REPO_TOKEN}" \
			"ParameterKey=UserName,ParameterValue=${OWNER}" \
			"ParameterKey=Region,ParameterValue=${REGION}" \
			"ParameterKey=EcsInstanceType,ParameterValue=t2.small" \
			"ParameterKey=SshKeyName,ParameterValue=${KEY_NAME}" \
			"ParameterKey=PublicDomainName,ParameterValue=${DOMAIN}" \
			"ParameterKey=ParameterStoreNamespace,ParameterValue=/bookit/${ENV}" \
			"ParameterKey=ServerRepository,ParameterValue=${OWNER}-${PROJECT}-server-ecr-repo" \
			"ParameterKey=WebRepository,ParameterValue=${OWNER}-${PROJECT}-web-ecr-repo" \
		--tags \
			"Key=Email,Value=${EMAIL}" \
			"Key=Environment,Value=${ENV}" \
			"Key=Owner,Value=${OWNER}" \
			"Key=ProjectName,Value=${OWNER}-${PROJECT}-${ENV}"


## Updates existing Foundation CF stack
update-foundation: upload-foundation
	@aws cloudformation update-stack --stack-name "${OWNER}-${PROJECT}-${ENV}-foundation" \
                --region ${REGION} \
		--template-body "file://cloudformation/foundation/main.yaml" \
		--capabilities CAPABILITY_NAMED_IAM \
		--parameters \
			"ParameterKey=CidrBlock,ParameterValue=10.1.0.0/16" \
			"ParameterKey=Environment,ParameterValue=${ENV}" \
			"ParameterKey=FoundationBucket,ParameterValue=rig.${OWNER}.${PROJECT}.${ENV}.${REGION}.foundation" \
			"ParameterKey=ProjectName,ParameterValue=${PROJECT}" \
			"ParameterKey=PublicDomainName,ParameterValue=${DOMAIN}" \
			"ParameterKey=Region,ParameterValue=${REGION}" \
			"ParameterKey=SubnetPrivateCidrBlocks,ParameterValue='10.1.11.0/24,10.1.12.0/24,10.1.13.0/24'" \
			"ParameterKey=SubnetPublicCidrBlocks,ParameterValue='10.1.1.0/24,10.1.2.0/24,10.1.3.0/24'" \
		--tags \
			"Key=Email,Value=${EMAIL}" \
			"Key=Environment,Value=${ENV}" \
			"Key=Owner,Value=${OWNER}" \
			"Key=ProjectName,Value=${OWNER}-${PROJECT}-${ENV}"


## Update existing App CF Stack
update-app: upload-app
	@aws cloudformation update-stack --stack-name "${OWNER}-${PROJECT}-${ENV}-app" \
                --region ${REGION} \
		--template-body "file://cloudformation/app/main.yaml" \
		--capabilities CAPABILITY_NAMED_IAM \
		--parameters \
			"ParameterKey=AppStackName,ParameterValue=${OWNER}-${PROJECT}-${ENV}" \
			"ParameterKey=BuildArtifactsBucket,ParameterValue=rig.${OWNER}.${PROJECT}.${ENV}.${REGION}.build" \
			"ParameterKey=Environment,ParameterValue=${ENV}" \
			"ParameterKey=FoundationStackName,ParameterValue=${OWNER}-${PROJECT}-${ENV}-foundation" \
			"ParameterKey=InfraDevBucket,ParameterValue=rig.${OWNER}.${PROJECT}.${ENV}.${REGION}.app" \
			"ParameterKey=ProjectName,ParameterValue=${PROJECT}" \
			"ParameterKey=RepositoryName,ParameterValue=${REPO}" \
			"ParameterKey=RepositoryBranch,ParameterValue=${REPO_BRANCH}" \
			"ParameterKey=RepositoryAuthToken,ParameterValue=${REPO_TOKEN}" \
			"ParameterKey=UserName,ParameterValue=${OWNER}" \
			"ParameterKey=Region,ParameterValue=${REGION}" \
			"ParameterKey=EcsInstanceType,ParameterValue=t2.small" \
			"ParameterKey=SshKeyName,ParameterValue=${KEY_NAME}" \
			"ParameterKey=PublicDomainName,ParameterValue=${DOMAIN}" \
			"ParameterKey=ParameterStoreNamespace,ParameterValue=/bookit/${ENV}" \
			"ParameterKey=ServerRepository,ParameterValue=${OWNER}-${PROJECT}-server-ecr-repo" \
            "ParameterKey=WebRepository,ParameterValue=${OWNER}-${PROJECT}-web-ecr-repo" \
		--tags \
			"Key=Email,Value=${EMAIL}" \
			"Key=Environment,Value=${ENV}" \
			"Key=Owner,Value=${OWNER}" \
			"Key=ProjectName,Value=${OWNER}-${PROJECT}-${ENV}"

## Print Foundation stack's status
status-foundation:
	@aws cloudformation describe-stacks \
                --region ${REGION} \
		--stack-name "${OWNER}-${PROJECT}-${ENV}-foundation" \
		--query "Stacks[][StackStatus] | []" | jq

## Print app stack's outputs
outputs-foundation:
	@aws cloudformation describe-stacks \
                --region ${REGION} \
		--stack-name "${OWNER}-${PROJECT}-${ENV}-foundation" \
		--query "Stacks[][Outputs] | []" | jq


## Print app stack's status
status-app:
	@aws cloudformation describe-stacks \
                --region ${REGION} \
		--stack-name "${OWNER}-${PROJECT}-${ENV}-app" \
		--query "Stacks[][StackStatus] | []" | jq


## Print app stack's outputs
outputs-app:
	@aws cloudformation describe-stacks \
                --region ${REGION} \
		--stack-name "${OWNER}-${PROJECT}-${ENV}-app" \
		--query "Stacks[][Outputs] | []" | jq


## Deletes the Foundation CF stack
delete-foundation:
	@if ${MAKE} .prompt-yesno message="Are you sure you wish to delete the Foundation Stack?"; then \
		aws cloudformation delete-stack --region ${REGION} --stack-name "${OWNER}-${PROJECT}-${ENV}-foundation"; \
	fi

## Deletes the App CF stack
delete-app:
	@if ${MAKE} .prompt-yesno message="Are you sure you wish to delete the Project ${PROJECT} Stack?"; then \
		aws cloudformation delete-stack --region ${REGION} --stack-name "${OWNER}-${PROJECT}-${ENV}-app"; \
	fi

## Upload CF Templates to S3
# Uploads foundation templates to the Foundation bucket
upload-foundation:
	@aws s3 cp --recursive cloudformation/foundation/ s3://rig.${OWNER}.${PROJECT}.${ENV}.${REGION}.foundation/templates/


## Upload CF Templates for project
# Note that these templates will be stored in your InfraDev Project **shared** bucket:
upload-app: upload-app-deployment
	@aws s3 cp --recursive cloudformation/app/ s3://rig.${OWNER}.${PROJECT}.${ENV}.${REGION}.app/templates/
	pwd=$(shell pwd)
	cd cloudformation/app/ && zip templates.zip *.yaml
	cd ${pwd}
	@aws s3 cp cloudformation/app/templates.zip s3://rig.${OWNER}.${PROJECT}.${ENV}.${REGION}.app/templates/
	rm -rf cloudformation/app/templates.zip
	@aws s3 cp cloudformation/app/service.yaml s3://rig.${OWNER}.${PROJECT}.${ENV}.${REGION}.app/templates/

## Upload app-deployment scripts to S3
# Uploads the app-deployment scripts to the build bucket
upload-app-deployment:
	@aws s3 cp --recursive app-deployment/ s3://rig.${OWNER}.${PROJECT}.${ENV}.${REGION}.build/app-deployment/


check-env:
ifndef OWNER
	$(error OWNER is undefined, should be in file .make)
endif
ifndef DOMAIN
	$(error DOMAIN is undefined, should be in file .make)
endif
ifndef EMAIL
	$(error EMAIL is undefined, should be in file .make)
endif
ifndef ENV
	$(error ENV is undefined, should be in file .make)
endif
ifndef KEY_NAME
	$(error KEY_NAME is undefined, should be in file .make)
endif
ifndef OWNER
	$(error OWNER is undefined, should be in file .make)
endif
ifndef PROFILE
	$(error PROFILE is undefined, should be in file .make)
endif
ifndef PROJECT
	$(error PROJECT is undefined, should be in file .make)
endif
ifndef REGION
	$(error REGION is undefined, should be in file .make)
endif
	@echo "All required ENV vars set"

## Print this help
help:
	@awk -v skip=1 \
		'/^##/ { sub(/^[#[:blank:]]*/, "", $$0); doc_h=$$0; doc=""; skip=0; next } \
		 skip  { next } \
		 /^#/  { doc=doc "\n" substr($$0, 2); next } \
		 /:/   { sub(/:.*/, "", $$0); printf "\033[34m%-30s\033[0m\033[1m%s\033[0m %s\n\n", $$0, doc_h, doc; skip=1 }' \
		${MAKEFILE_LIST}


.CLEAR=\x1b[0m
.BOLD=\x1b[01m
.RED=\x1b[31;01m
.GREEN=\x1b[32;01m
.YELLOW=\x1b[33;01m

# Re-usable target for yes no prompt. Usage: make .prompt-yesno message="Is it yes or no?"
# Will exit with error if not yes
.prompt-yesno:
	$(eval export RESPONSE="${shell read -t5 -n1 -p "${message} [Yy]: " && echo "$$REPLY" | tr -d '[:space:]'}")
	@case ${RESPONSE} in [Yy]) \
			echo "\n${.GREEN}[Continuing]${.CLEAR}" ;; \
		*) \
			echo "\n${.YELLOW}[Cancelled]${.CLEAR}" && exit 1 ;; \
	esac


.make:
	@touch .make
	@scripts/build-dotmake.sh

.DEFAULT_GOAL := help
.PHONY: help
.PHONY: deps check-env get-ubuntu-ami .prompt-yesno
