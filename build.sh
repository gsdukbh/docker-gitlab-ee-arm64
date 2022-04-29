#!/bin/bash

cat version_list | while read version; do
    echo ${version}
    HAVE_TAG=false
    for tag in $(git tag); do
        if [ "${version}" == "${tag}" ]; then
            HAVE_TAG=true
        fi
    done
    if ! ${HAVE_TAG}; then
        git tag ${version}
    fi
done

LATEST=$(git tag | sort -rV | head -n 1)

if [ -f ./latest ]; then
    old= cat ./latest
else
    echo LATEST > latest
    old=1
fi

if  test $old != LATEST ; then
    echo LATEST > latest
    git clone https://gitlab.com/gitlab-org/omnibus-gitlab.git
    cd omnibus-gitlab/docker
    echo "PACKAGECLOUD_REPO=gitlab-ee" > RELEASE 
    echo "RELEASE_PACKAGE=gitlab-ee" >> RELEASE
    echo "RELEASE_VERSION=${LATEST}" >> RELEASE
    echo "DOWNLOAD_URL=https://packages.gitlab.com/gitlab/gitlab-ee/packages/ubuntu/focal/gitlab-ee_${LATEST}_arm64.deb/download.deb" >> RELEASE
    sed -i 's/\-recommends/\-recommends libatomic1/' Dockerfile
    docker run --privileged --rm tonistiigi/binfmt --install all
    docker buildx  build --platform linux/arm64 -t ${DOCKER_NAME}/gitlab-ee-arm64:${LATEST} -f Dockerfile ./ 
    cd ../../
    docker tag ${DOCKER_NAME}/gitlab-ee-arm64:${LATEST} ${DOCKER_NAME}/gitlab-ee-arm64:latest;
    docker login --username ${DOCKER_NAME} --password ${DOCKER_PASSWORD} 
    docker push -a ${DOCKER_NAME}/gitlab-ee-arm64
    git config --local user.email ${MAIL}
    git config --local user.name ${MY_NAME}
    git add latest
    git commit -m "build version ${LATEST}"
fi