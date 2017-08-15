#!/usr/bin/env bash

echo 'Please provide the following AWS parameter store values'
echo
read -p 'Environment name: ' ENV_NAME
read -p 'Use Azure (true, false): ' USE_AZURE
read -p 'Azure secret: ' AZURE_SECRET
echo

aws ssm put-parameter --name "/bookit/${ENV_NAME}/USE_AZURE" --description "Use GraphAPI or not" --type "String" --value "${USE_AZURE}" --overwrite
aws ssm put-parameter --name "/bookit/${ENV_NAME}/AZURE_SECRET" --description "The secret key to use GraphAPI" --type "SecureString" --value "${AZURE_SECRET}" --overwrite

echo 'Saved parameters!'
echo
