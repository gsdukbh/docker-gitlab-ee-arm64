# docker-gitlab-ee-arm64
build gitlab-ee for arm64 images

-- test

# how to use this

docker compose 

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
