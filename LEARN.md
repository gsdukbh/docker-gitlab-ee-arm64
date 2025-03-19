# Use Github Actions to Build Docker Images

## Project Overview

[![build-tags](https://github.com/gsdukbh/docker-gitlab-ee-arm64/actions/workflows/build.yml/badge.svg)](https://github.com/gsdukbh/docker-gitlab-ee-arm64/actions/workflows/build.yml)   [![check-build-tags](https://github.com/gsdukbh/docker-gitlab-ee-arm64/actions/workflows/blank.yml/badge.svg)](https://github.com/gsdukbh/docker-gitlab-ee-arm64/actions/workflows/blank.yml)


This project aims to provide **ARM64 architecture** Docker image build support for **GitLab EE**. Through automated scripts and GitHub Actions workflows, users can easily build, manage, and publish GitLab EE images for ARM64.

Key features include:
- Automatically detect the latest GitLab EE version.
- Build and push Docker images for the ARM64 architecture.
- Use GitHub Actions to achieve continuous integration and automated builds.
- Provide Docker Compose examples for quick deployment.

---

## Learning Guide

### 1. Project Structure

- **Script Files**
  - `build-tag.sh`: Used to build Docker images for specific versions.
  - `build.sh`: Checks for missing tags and builds corresponding images.
  - `check-version.sh`: Fetches the latest version information from GitLab's official source.
  - `test.sh`: A simple script for testing environment variables.

- **Configuration Files**
  - `.github/workflows/build.yml`: GitHub Actions workflow for manually triggering builds.
  - `.github/workflows/blank.yml`: Scheduled workflow for checking and building new versions.

- **Data Files**
  - `version`: Records all built versions.
  - `latest`: Records the latest version number.

- **Documentation**
  - `README.md`: Usage instructions and Docker Compose examples for the project.
  - `LEARN.md`: Learning guide and project overview.

---

### 2. How to Use

1. **Build Images**
   - Manually run `build-tag.sh` or trigger builds via GitHub Actions.
   - After the build is complete, the image will be pushed to Docker Hub.

2. **Automated Builds**
   - Configure GitHub Secrets:
     - `DOCKER_PASSWORD`: Docker Hub password.
     - `MAIL`: Email for Git commits.
     - `MY_NAME`: Username for Git commits.
   - Use `build.yml` to manually trigger builds or `blank.yml` to periodically check for new versions.

3. **Deployment**
   - Use the Docker Compose examples in `README.md` to quickly start the GitLab EE service.

---

### 3. Key Learning Points

- **GitHub Actions**: Learn how to configure and use workflows for automated builds.
- **Docker Multi-Architecture Support**: Understand how to use `docker buildx` to build ARM64 images.
- **Version Management**: Automatically detect and manage versions through scripts.
- **Continuous Integration**: Implement a complete CI/CD process with Git and Docker.

---

Through this project, you can deeply learn how to build and manage Docker images for the ARM64 architecture and master best practices for automated builds and deployments.

