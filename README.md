# docker-gitlab-ee-arm64

build gitlab-ee for arm64 images

[![build-tags](https://github.com/gsdukbh/docker-gitlab-ee-arm64/actions/workflows/build.yml/badge.svg)](https://github.com/gsdukbh/docker-gitlab-ee-arm64/actions/workflows/build.yml)  [![check-build-tags](https://github.com/gsdukbh/docker-gitlab-ee-arm64/actions/workflows/blank.yml/badge.svg)](https://github.com/gsdukbh/docker-gitlab-ee-arm64/actions/workflows/blank.yml)

 > 此项目是为了在 **[Raspberry Pi4](https://www.raspberrypi.com/)** 上运行Gitlab 而创建。

This project aims to provide **ARM64 architecture** Docker image build support for **GitLab EE**. Through automated scripts and GitHub Actions workflows, users can easily build, manage, and publish GitLab EE images for ARM64.


# learn this project

[learn.md](LEARN.md)

# how upgrade

[upgrade path](https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/)

# how to use this

## Using Docker Compose

To deploy GitLab EE for ARM64 using Docker Compose, follow these steps:

1. Ensure you have Docker and Docker Compose installed on your system.
2. Create a `docker-compose.yml` file with the configuration provided above.
3. Run the following command to start the services:

  ```bash
  docker-compose up -d
  ```

4. Access GitLab in your browser at `http://<your-server-ip>`.

For additional configuration or troubleshooting, refer to the official GitLab documentation.

```yaml
version: '3.7'
services:
  gitlab:
    image: gsdukbh/gitlab-ee-arm64:latest
    container_name: gitlab
    volumes:
      - ./license.rb:/opt/gitlab/embedded/service/gitlab-rails/ee/app/models/license.rb
      - ./license_key.pub://opt/gitlab/embedded/service/gitlab-rails/.license_encryption_key.pub 
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
