    echo "Processing tag: ${LATEST}"
    git clone https://gitlab.com/gitlab-org/omnibus-gitlab.git
    cd omnibus-gitlab/docker
    echo "PACKAGECLOUD_REPO=gitlab-ee" > RELEASE
    echo "TARGETARCH=arm64" >> RELEASE
    echo "RELEASE_PACKAGE=gitlab-ee" >> RELEASE
    echo "RELEASE_VERSION=${LATEST}" >> RELEASE
    echo "DOWNLOAD_URL_arm64=https://packages.gitlab.com/gitlab/gitlab-ee/packages/ubuntu/focal/gitlab-ee_${LATEST}_arm64.deb/download.deb" >> RELEASE
    sed -i 's/\-recommends/\-recommends libatomic1/' Dockerfile
    docker run --privileged --rm tonistiigi/binfmt --install all
    docker buildx  build --platform linux/arm64 -t ${DOCKER_NAME}/gitlab-ee-arm64:${LATEST} -f Dockerfile ./
    cd ../../
    docker images
    docker tag ${DOCKER_NAME}/gitlab-ee-arm64:${LATEST} ${DOCKER_NAME}/gitlab-ee-arm64:latest;
    docker login --username ${DOCKER_NAME} --password ${DOCKER_PASSWORD}
    docker push -a ${DOCKER_NAME}/gitlab-ee-arm64
