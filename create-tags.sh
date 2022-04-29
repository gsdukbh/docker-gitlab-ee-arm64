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
        # get omnibus
        sudo git clone https://gitlab.com/gitlab-org/omnibus-gitlab.git
        cd omnibus-gitlab/docker
        echo "PACKAGECLOUD_REPO=gitlab-ee" > RELEASE 
        echo "RELEASE_PACKAGE=gitlab-ee" >> RELEASE
        echo "RELEASE_VERSION=${version}" >> RELEASE
        echo "DOWNLOAD_URL=https://packages.gitlab.com/gitlab/gitlab-ee/packages/ubuntu/focal/gitlab-ee_${version}_arm64.deb/download.deb" >> RELEASE
        sed -i 's/\-recommends/\-recommends libatomic1/' Dockerfile
        sudo docker buildx  build --platform linux/arm64 -t ${DOCKER_NAME}/gitlab-ee-arm64:${version} -f Dockerfile ./ 
        cd ../../
        LATEST=$(git tag | sort -rV | head -n 1)
        if [ "${LATEST}" == "${version}" ]; then 
             docker tag ${DOCKER_NAME}/gitlab-ee-arm64:${version} ${DOCKER_NAME}/gitlab-ee-arm64:latest;
        fi
        docker login --username ${DOCKER_NAME} --password ${DOCKER_PASSWORD} 
        docker push -a ${DOCKER_NAME}/gitlab-ee-arm64

    fi
done
