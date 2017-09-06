#!/bin/bash

echo 'Creating build user...'
echo

if [[ -z $1 && -z $2 ]] ; then
    echo 'Missing command line arguments'
    echo 'USAGE: create-build-user.sh <Owner> <Project>'
    exit 1
fi

OWNER=$1
PROJECT=$2

aws iam create-user --user-name "${OWNER}-${PROJECT}" > created-user-out-credentials.json
aws iam create-access-key --user-name "${OWNER}-${PROJECT}" >> created-user-out-credentials.json
aws iam put-user-policy --user-name "${OWNER}-${PROJECT}" --policy-name Ecr --policy-document file://scripts/EcrPolicy.json
aws iam put-user-policy --user-name "${OWNER}-${PROJECT}" --policy-name Ecs --policy-document file://scripts/EcsPolicy.json
aws iam put-user-policy --user-name "${OWNER}-${PROJECT}" --policy-name S3 --policy-document file://scripts/S3Policy.json
aws iam put-user-policy --user-name "${OWNER}-${PROJECT}" --policy-name Ssm --policy-document file://scripts/SsmPolicy.json

echo
echo "Look in created-user-out-credentials.json for generated values."
