#!/bin/bash
set -euo pipefail  # Exit on error, undefined variables, and pipe failures

# Validate required environment variables
: "${DOCKER_NAME:?Environment variable DOCKER_NAME is required}"
: "${DOCKER_PASSWORD:?Environment variable DOCKER_PASSWORD is required}"
: "${LATEST:?Environment variable LATEST is required}"

echo "==================================="
echo "Processing tag: ${LATEST}"
echo "==================================="

# Clean up any previous clone
rm -rf omnibus-gitlab

# Clone the GitLab Omnibus repository
echo "Cloning GitLab Omnibus repository..."
git clone --depth=1 https://gitlab.com/gitlab-org/omnibus-gitlab.git

cd omnibus-gitlab/docker
pwd

# Create a RELEASE file with necessary environment variables for the build.
echo "Creating RELEASE file for ARM64 build..."
cat > RELEASE << EOF
PACKAGECLOUD_REPO=gitlab-ee
RELEASE_PACKAGE=gitlab-ee
RELEASE_VERSION=${LATEST}
DOWNLOAD_URL_arm64=https://packages.gitlab.com/gitlab/gitlab-ee/packages/ubuntu/jammy/gitlab-ee_${LATEST}_arm64.deb/download.deb
EOF

echo "RELEASE file contents:"
cat RELEASE

# Check if libatomic1 is already in Dockerfile (official version already includes it)
if grep -q "libatomic1" Dockerfile; then
    echo "✅ libatomic1 already present in Dockerfile (official version)"
else
    echo "⚠️  Adding libatomic1 to Dockerfile..."
    sed -i.bak 's/--no-install-recommends \\/--no-install-recommends libatomic1 \\/' Dockerfile
fi

# Enable multi-platform builds using binfmt
echo "Setting up QEMU for ARM64 emulation..."
sudo docker run --privileged --rm tonistiigi/binfmt --install all

# Create or use existing buildx builder
echo "Setting up Docker buildx..."
sudo docker buildx create --use --name gitlab-builder --driver docker-container 2>/dev/null || sudo docker buildx use gitlab-builder || true
sudo docker buildx inspect --bootstrap

# Build the Docker image for the ARM64 platform
echo "Building Docker image for ARM64..."
echo "Image: ${DOCKER_NAME}/gitlab-ee-arm64:${LATEST}"

sudo docker buildx build \
  --platform linux/arm64 \
  --build-arg TARGETARCH=arm64 \
  --build-arg BASE_IMAGE=ubuntu:24.04 \
  --tag ${DOCKER_NAME}/gitlab-ee-arm64:${LATEST} \
  --tag ${DOCKER_NAME}/gitlab-ee-arm64:latest \
  --file Dockerfile \
  --load \
  ./

echo "✅ Build completed successfully"

# Navigate back to the root directory
cd ../../

# List built images
echo "Built images:"
sudo docker images | grep gitlab-ee-arm64

# Log in to Docker Hub
echo "Logging in to Docker Hub..."
echo "${DOCKER_PASSWORD}" | sudo docker login --username ${DOCKER_NAME} --password-stdin

# Push images to Docker Hub
echo "Pushing images to Docker Hub..."
sudo docker push ${DOCKER_NAME}/gitlab-ee-arm64:${LATEST}
sudo docker push ${DOCKER_NAME}/gitlab-ee-arm64:latest

echo "✅ Successfully pushed image for tag: ${LATEST}"

# Clean up local images to save disk space
echo "Cleaning up local images..."
sudo docker rmi -f ${DOCKER_NAME}/gitlab-ee-arm64:latest 2>/dev/null || true
sudo docker rmi -f ${DOCKER_NAME}/gitlab-ee-arm64:${LATEST} 2>/dev/null || true

# Clean up cloned repository
echo "Cleaning up cloned repository..."
cd ../..
rm -rf omnibus-gitlab

echo "✅ Build process completed successfully for ${LATEST}"