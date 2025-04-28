echo "Processing tag: ${LATEST}" # Print the tag being processed.
git clone https://gitlab.com/gitlab-org/omnibus-gitlab.git # Clone the GitLab Omnibus repository.
cd omnibus-gitlab/docker # Navigate to the Docker directory.

# Create a RELEASE file with necessary environment variables for the build.
echo "PACKAGECLOUD_REPO=gitlab-ee" > RELEASE
echo "TARGETARCH=arm64" >> RELEASE
echo "RELEASE_PACKAGE=gitlab-ee" >> RELEASE
echo "RELEASE_VERSION=${LATEST}" >> RELEASE
echo "DOWNLOAD_URL_arm64=https://packages.gitlab.com/gitlab/gitlab-ee/packages/ubuntu/focal/gitlab-ee_${LATEST}_arm64.deb/download.deb" >> RELEASE

# Modify the Dockerfile to include the 'libatomic1' package as a dependency.
sed -i 's/\-recommends/\-recommends libatomic1/' Dockerfile

# Enable multi-platform builds using binfmt.
sudo docker run --privileged --rm tonistiigi/binfmt --install all

# Build the Docker image for the ARM64 platform.
sudo docker buildx build --platform linux/arm64 -t ${DOCKER_NAME}/gitlab-ee-arm64:${LATEST} -f Dockerfile ./

cd ../../ # Navigate back to the root directory.

sudo docker images # List all Docker images.

# Tag the built image with the 'latest' tag.
sudo docker tag ${DOCKER_NAME}/gitlab-ee-arm64:${LATEST} ${DOCKER_NAME}/gitlab-ee-arm64:latest;

# Log in to Docker Hub using the provided credentials.
sudo docker login --username ${DOCKER_NAME} --password ${DOCKER_PASSWORD}

# Push all tags of the image to Docker Hub.
sudo docker push -a ${DOCKER_NAME}/gitlab-ee-arm64
