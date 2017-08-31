#!/bin/bash

function makeRepo() {
    SERVER_REPO="${OWNER}-${PROJECT}-${1}-ecr-repo"
    echo "Creating repository: ${SERVER_REPO}"
    aws ecr create-repository --repository-name ${SERVER_REPO} --region ${REGION}
}

makeRepo server
makeRepo web

