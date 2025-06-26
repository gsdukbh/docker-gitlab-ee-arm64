#!/bin/bash

# Define an array to store tags that do not match existing ones
no_match_tags=()
while read -r latest; do
    HAVE_TAG=false
    # Check if the current tag exists in the git repository
    for tag in $(git tag); do
        if [ "${latest}" == "${tag}" ]; then
            HAVE_TAG=true
        fi
    done
    # If the tag does not exist, create it and add it to the no_match_tags array
    if ! ${HAVE_TAG}; then
        git tag ${latest}
        echo ${latest}
        no_match_tags+=("${latest}")
    fi
done < latest

# LATEST=$(git tag | sort -rV | head -n 1)

# if [ -f ./latest ]; then
#     old= cat ./latest
# else
#     echo $LATEST > latest
#     old=1
# fi

# Build images for the missing tags
for LATEST in "${no_match_tags[@]}"; do
    echo "Processing tag: ${LATEST}"
    echo $LATEST >> version
    # Clone the GitLab Omnibus repository
    git clone https://gitlab.com/gitlab-org/omnibus-gitlab.git
    cd omnibus-gitlab/docker
    # Set up the release configuration for arm64 architecture
    echo "TARGETARCH=arm64" >> RELEASE
    echo "RELEASE_PACKAGE=gitlab-ee" >> RELEASE
    echo "RELEASE_VERSION=${LATEST}" >> RELEASE
    echo "DOWNLOAD_URL_arm64=https://packages.gitlab.com/gitlab/gitlab-ee/packages/ubuntu/focal/gitlab-ee_${LATEST}_arm64.deb/download.deb" >> RELEASE
    sed -i 's/\-recommends/\-recommends libatomic1/' Dockerfile
    sudo docker run --privileged --rm tonistiigi/binfmt --install all
    sudo docker buildx  build --platform linux/arm64 -t ${DOCKER_NAME}/gitlab-ee-arm64:${LATEST} -f Dockerfile ./
    cd ../../
    sudo docker tag ${DOCKER_NAME}/gitlab-ee-arm64:${LATEST} ${DOCKER_NAME}/gitlab-ee-arm64:latest;
    sudo docker login --username ${DOCKER_NAME} --password ${DOCKER_PASSWORD}
    sudo docker push -a ${DOCKER_NAME}/gitlab-ee-arm64
    git add latest
    git add version 
    git config --local user.email ${MAIL}
    git config --local user.name ${MY_NAME}
    git commit -a -m "build version ${LATEST}"
    
done

# if  test "$old" != "$LATEST" ; then
#     echo $LATEST > latest
#     git clone https://gitlab.com/gitlab-org/omnibus-gitlab.git
#     cd omnibus-gitlab/docker
#     echo "PACKAGECLOUD_REPO=gitlab-ee" > RELEASE
#     echo "RELEASE_PACKAGE=gitlab-ee" >> RELEASE
#     echo "RELEASE_VERSION=${LATEST}" >> RELEASE
#     echo "DOWNLOAD_URL=https://packages.gitlab.com/gitlab/gitlab-ee/packages/ubuntu/focal/gitlab-ee_${LATEST}_arm64.deb/download.deb" >> RELEASE
#     sed -i 's/\-recommends/\-recommends libatomic1/' Dockerfile
#     docker run --privileged --rm tonistiigi/binfmt --install all
#     docker buildx  build --platform linux/arm64 -t ${DOCKER_NAME}/gitlab-ee-arm64:${LATEST} -f Dockerfile ./
#     cd ../../
#     docker tag ${DOCKER_NAME}/gitlab-ee-arm64:${LATEST} ${DOCKER_NAME}/gitlab-ee-arm64:latest;
#     docker login --username ${DOCKER_NAME} --password ${DOCKER_PASSWORD}
#     docker push -a ${DOCKER_NAME}/gitlab-ee-arm64
#     git add latest
#     git config --local user.email ${MAIL}
#     git config --local user.name ${MY_NAME}
#     git commit -a -m "build version ${LATEST}"
# fi
