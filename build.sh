#!/bin/bash
set -euo pipefail  # Exit on error, undefined variables, and pipe failures

# Validate required environment variables
: "${DOCKER_NAME:?Environment variable DOCKER_NAME is required}"
: "${DOCKER_PASSWORD:?Environment variable DOCKER_PASSWORD is required}"

echo "==================================="
echo "Checking for new versions to build"
echo "==================================="

# Define an array to store tags that do not match existing ones
no_match_tags=()
while read -r latest; do
    # Skip empty lines
    [[ -z "$latest" ]] && continue
    
    HAVE_TAG=false
    # Check if the current tag exists in the git repository
    for tag in $(git tag); do
        if [ "${latest}" == "${tag}" ]; then
            HAVE_TAG=true
            break
        fi
    done
    # If the tag does not exist, create it and add it to the no_match_tags array
    if ! ${HAVE_TAG}; then
        git tag ${latest}
        echo "New version found: ${latest}"
        no_match_tags+=("${latest}")
    fi
done < latest

echo "Found ${#no_match_tags[@]} new version(s) to build"

# LATEST=$(git tag | sort -rV | head -n 1)

# if [ -f ./latest ]; then
#     old= cat ./latest
# else
#     echo $LATEST > latest
#     old=1
# fi

# Build images for the missing tags
for LATEST in "${no_match_tags[@]}"; do
    echo ""
    echo "==================================="
    echo "Building version: ${LATEST}"
    echo "==================================="
    
    # Record version
    echo $LATEST >> version
    
    # Clean up any previous clone
    rm -rf omnibus-gitlab
    
    # Clone the GitLab Omnibus repository
    echo "Cloning GitLab Omnibus repository..."
    git clone --depth=1 https://gitlab.com/gitlab-org/omnibus-gitlab.git
    
    cd omnibus-gitlab/docker
    
    # Set up the release configuration for arm64 architecture
    echo "Creating RELEASE file..."
    cat > RELEASE << EOF
PACKAGECLOUD_REPO=gitlab-ee
RELEASE_PACKAGE=gitlab-ee
RELEASE_VERSION=${LATEST}
DOWNLOAD_URL_arm64=https://packages.gitlab.com/gitlab/gitlab-ee/packages/ubuntu/jammy/gitlab-ee_${LATEST}_arm64.deb/download.deb
EOF
    
    # Check if libatomic1 is already in Dockerfile
    if grep -q "libatomic1" Dockerfile; then
        echo "✅ libatomic1 already present in Dockerfile"
    else
        echo "⚠️  Adding libatomic1 to Dockerfile..."
        sed -i.bak 's/--no-install-recommends \\/--no-install-recommends libatomic1 \\/' Dockerfile
    fi
    
    # Enable multi-platform builds
    echo "Setting up QEMU for ARM64 emulation..."
    sudo docker run --privileged --rm tonistiigi/binfmt --install all
    
    # Create or use existing buildx builder
    sudo docker buildx create --use --name gitlab-builder --driver docker-container 2>/dev/null || sudo docker buildx use gitlab-builder || true
    sudo docker buildx inspect --bootstrap
    
    # Build the image
    echo "Building Docker image..."
    sudo docker buildx build \
      --platform linux/arm64 \
      --build-arg TARGETARCH=arm64 \
      --build-arg BASE_IMAGE=ubuntu:24.04 \
      --tag ${DOCKER_NAME}/gitlab-ee-arm64:${LATEST} \
      --tag ${DOCKER_NAME}/gitlab-ee-arm64:latest \
      --file Dockerfile \
      --load \
      ./
    
    cd ../../
    
    # Login to Docker Hub
    echo "Logging in to Docker Hub..."
    echo "${DOCKER_PASSWORD}" | sudo docker login --username ${DOCKER_NAME} --password-stdin
    
    # Push images
    echo "Pushing images to Docker Hub..."
    sudo docker push ${DOCKER_NAME}/gitlab-ee-arm64:${LATEST}
    sudo docker push ${DOCKER_NAME}/gitlab-ee-arm64:latest
    
    echo "✅ Successfully pushed ${LATEST}"
    
    # Commit changes to git
    git add latest version
    git config --local user.email ${MAIL}
    git config --local user.name ${MY_NAME}
    git commit -m "build version ${LATEST}" || true
    
    # Clean up docker images to save space
    echo "Cleaning up local images..."
    sudo docker rmi -f ${DOCKER_NAME}/gitlab-ee-arm64:latest 2>/dev/null || true
    sudo docker rmi -f ${DOCKER_NAME}/gitlab-ee-arm64:${LATEST} 2>/dev/null || true
    
    # Clean up cloned repository
    rm -rf omnibus-gitlab
    
    echo "✅ Completed build for ${LATEST}"
done

echo ""
echo "==================================="
echo "All builds completed successfully!"
echo "==================================="

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
