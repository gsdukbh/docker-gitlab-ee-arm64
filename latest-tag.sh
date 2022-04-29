#!/bin/bash

LATEST=$(git tag | sort -rV | head -n 1)
echo ${LATEST}
git tag -a ${LATEST} -m "latest version"
# if [ "${LATEST}" == "${CI_COMMIT_TAG}" ]; then 
#     docker tag ${DOCKER_NS}/${BASENAME}:${CI_COMMIT_TAG} ${DOCKER_NS}/${BASENAME}:latest;
# fi
