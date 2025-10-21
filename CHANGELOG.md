# Changelog

## 2025-10-21 - Build Script Improvements

### 🎉 Major Updates

Based on the official GitLab Omnibus repository build method, the build scripts have been significantly improved.

### ✨ Key Changes

#### 1. **Aligned with Official Build Method**
- Updated to use the official GitLab Omnibus Dockerfile structure
- **Ubuntu 24.04** as base image (was 20.04 focal)
- **libatomic1** is now included by default in official Dockerfiles (no need for sed modifications in newer versions)
- Changed download URL from `focal` to `jammy` (Ubuntu 22.04) for better compatibility

#### 2. **Enhanced Error Handling**
- Added `set -euo pipefail` for robust error handling
- Added environment variable validation
- Better error messages and logging

#### 3. **Improved Build Process**
- Uses `--depth=1` for faster git cloning
- Proper buildx builder management with `--driver docker-container`
- Added `TARGETARCH` and `BASE_IMAGE` build arguments
- Uses `--load` to load images into local Docker daemon
- Cleaner resource cleanup after each build

#### 4. **Better Docker Hub Integration**
- Uses `--password-stdin` for secure Docker login
- Separate push commands for each tag
- Better error handling for push operations

#### 5. **Resource Management**
- Removes cloned omnibus-gitlab repository after each build
- Uses `-f` flag for force removal of images
- Better disk space management

### 📝 Modified Files

#### `build-tag.sh`
- Complete rewrite based on official build method
- Added comprehensive logging
- Improved error handling and validation
- Better cleanup procedures

#### `build.sh`
- Aligned with changes in `build-tag.sh`
- Added progress indicators
- Better version tracking
- Improved git commit handling

### 🔧 Technical Details

#### RELEASE File Format
```bash
PACKAGECLOUD_REPO=gitlab-ee
RELEASE_PACKAGE=gitlab-ee
RELEASE_VERSION=18.x.x-ee.0
DOWNLOAD_URL_arm64=https://packages.gitlab.com/gitlab/gitlab-ee/packages/ubuntu/jammy/gitlab-ee_VERSION_arm64.deb/download.deb
```

#### Build Command
```bash
docker buildx build \
  --platform linux/arm64 \
  --build-arg TARGETARCH=arm64 \
  --build-arg BASE_IMAGE=ubuntu:24.04 \
  --tag ${DOCKER_NAME}/gitlab-ee-arm64:${VERSION} \
  --tag ${DOCKER_NAME}/gitlab-ee-arm64:latest \
  --file Dockerfile \
  --load \
  ./
```

### ⚠️ Breaking Changes

- **Ubuntu version**: Changed from 20.04 (focal) to 22.04 (jammy) for deb downloads
- **Base image**: Now uses Ubuntu 24.04 as default base image
- **Build args**: Added required build arguments for proper multi-arch support

### 🎯 Benefits

1. **Official Compatibility**: Builds now match official GitLab Docker image structure
2. **Better Maintainability**: Easier to keep in sync with official changes
3. **Improved Reliability**: Better error handling and validation
4. **Resource Efficiency**: Proper cleanup and resource management
5. **Future Proof**: Ready for GitLab's official build practices

### 📚 References

- Official GitLab Omnibus Repository: https://gitlab.com/gitlab-org/omnibus-gitlab
- Official Dockerfile: https://gitlab.com/gitlab-org/omnibus-gitlab/-/blob/master/docker/Dockerfile
- GitLab Docker Documentation: https://docs.gitlab.com/ee/install/docker.html

### 🚀 Next Steps

For GitLab 18.1+, users should consider migrating to official images:
```bash
docker pull gitlab/gitlab-ee:latest
```

This project continues to support GitLab 18.0 and earlier versions.
