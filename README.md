# docker-gitlab-ee-arm64

build gitlab-ee for arm64 images

[![build-tags](https://github.com/gsdukbh/docker-gitlab-ee-arm64/actions/workflows/build.yml/badge.svg)](https://github.com/gsdukbh/docker-gitlab-ee-arm64/actions/workflows/build.yml)  [![check-build-tags](https://github.com/gsdukbh/docker-gitlab-ee-arm64/actions/workflows/blank.yml/badge.svg)](https://github.com/gsdukbh/docker-gitlab-ee-arm64/actions/workflows/blank.yml)

> ⚠️ **Important Update (2025+)**:
> - **GitLab officially supports ARM64 architecture starting from version 18.1** 🎉
> - If you need **GitLab 18.1 or newer**, we recommend using the official image: `gitlab/gitlab-ee:latest`
> - This project primarily provides ARM64 support for **GitLab 18.0 and earlier versions**
> - Official image: https://hub.docker.com/r/gitlab/gitlab-ee

> This project was created to run GitLab on **[Raspberry Pi 4](https://www.raspberrypi.com/)**.

This project aims to provide **ARM64 architecture** Docker image build support for **GitLab EE**. Through automated scripts and GitHub Actions workflows, users can easily build, manage, and publish GitLab EE images for ARM64.

## 🆕 GitLab Official ARM64 Support

**GitLab officially supports ARM64 starting from version 18.1!**

### For GitLab 18.1 and newer (Recommended)

Use the official multi-architecture image:

```bash
# Docker will automatically pull the ARM64 version on ARM64 platforms
docker pull gitlab/gitlab-ee:latest
# Or specify a version (18.1+)
docker pull gitlab/gitlab-ee:18.1.0-ee.0
```

```yaml
version: '3.7'
services:
  gitlab:
    image: gitlab/gitlab-ee:latest  # Official ARM64 support
    container_name: gitlab
    volumes:
      - './gitlab/config:/etc/gitlab'
      - './gitlab/log:/var/log/gitlab'
      - './gitlab/data:/var/opt/gitlab'
    restart: always
    ports:
      - '80:80'
      - '443:443'
      - '22:22'
```

### For GitLab 18.0 and earlier

Use this project's images for older versions that don't have official ARM64 support:

```bash
docker pull gsdukbh/gitlab-ee-arm64:18.0.6-ee.0
docker pull gsdukbh/gitlab-ee-arm64:17.11.7-ee.0
docker pull gsdukbh/gitlab-ee-arm64:16.11.10-ee.0
```


# learn this project

[learn.md](LEARN.md)

# how upgrade

[upgrade path](https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/)

---

# how to use this

## Option 1: Using Official GitLab Images (GitLab 18.1+) - Recommended

For GitLab version 18.1 and above, use the official images with native ARM64 support:

```yaml
version: '3.7'
services:
  gitlab:
    image: gitlab/gitlab-ee:latest  # Official multi-arch image
    container_name: gitlab
    hostname: 'gitlab.example.com'
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'http://gitlab.example.com'
    volumes:
      - './gitlab/config:/etc/gitlab'
      - './gitlab/log:/var/log/gitlab'
      - './gitlab/data:/var/opt/gitlab'
    shm_size: '256m'
    restart: always
    ports:
      - '80:80'
      - '443:443'
      - '22:22'
```

Then run:
```bash
docker-compose up -d
```

## Option 2: Using This Project's Images (GitLab 18.0 and earlier)

To deploy older GitLab EE versions for ARM64 using Docker Compose:

1. Ensure you have Docker and Docker Compose installed on your system.
2. Create a `docker-compose.yml` file with the configuration below.
3. Run the following command to start the services:

  ```bash
  docker-compose up -d
  ```

4. Access GitLab in your browser at `http://<your-server-ip>`.

For additional configuration or troubleshooting, refer to the official GitLab documentation.

**Example docker-compose.yml for GitLab 17.x/18.0:**

```yaml
version: '3.7'
services:
  gitlab:
    image: gsdukbh/gitlab-ee-arm64:18.0.6-ee.0  # Use specific version tag
    container_name: gitlab
    volumes:
      # Optional: license files for GitLab EE features
      # - ./license.rb:/opt/gitlab/embedded/service/gitlab-rails/ee/app/models/license.rb
      # - ./license_key.pub:/opt/gitlab/embedded/service/gitlab-rails/.license_encryption_key.pub 
      - './gitlab/config:/etc/gitlab'
      - './gitlab/log:/var/log/gitlab'
      - './gitlab/data:/var/opt/gitlab'
    restart: always
    ports:
      - '80:80'
      - '8090:8090'
      - '22:22'
    links:
      - 'ES:elasticsearch'
  git-runner:
    image: gitlab/gitlab-runner:latest
    container_name: runner
    volumes:
      - '/var/run/docker.sock:/var/run/docker.sock'
      - './runner/config:/etc/gitlab-runner'
    restart: always
    links:
     - 'gitlab:gitlab'
  ES:
    image: elasticsearch:8.11.0
    container_name: elasticsearch8
    restart: always
    volumes:
      - es_data:/usr/share/elasticsearch/data
    environment:
      - discovery.type=single-node
      # - ELASTIC_USERNAME=elastic
      - ELASTIC_PASSWORD=7gzXgeo0w11vPtEmniyJ
      - ES_JAVA_OPTS=-Xms1024m 
    ports:
      - 9200:9200
      - 9300:9300
volumes:
  es_data:       

```

## Version Support

| GitLab Version | ARM64 Support | Recommended Image |
|---------------|---------------|-------------------|
| 18.1+ | ✅ Official | `gitlab/gitlab-ee:latest` or `gitlab/gitlab-ee:18.x.x-ee.0` |
| 18.0 | ⚠️ This Project | `gsdukbh/gitlab-ee-arm64:18.0.x-ee.0` |
| 17.x | ⚠️ This Project | `gsdukbh/gitlab-ee-arm64:17.x.x-ee.0` |
| 16.x | ⚠️ This Project | `gsdukbh/gitlab-ee-arm64:16.x.x-ee.0` |
| 15.x and older | ⚠️ This Project | `gsdukbh/gitlab-ee-arm64:15.x.x-ee.0` |

**Note**: For GitLab 18.1+, we strongly recommend using the official images for better support and updates.
