#!/bin/bash

function removeRepo() {
    SERVER_REPO="${OWNER}-${PROJECT}-${1}-ecr-repo"
    echo "Deleting repository: ${SERVER_REPO}"
    aws ecr delete-repository --repository-name ${SERVER_REPO} --region ${REGION}
}

removeRepo server
removeRepo web

