# Use Github Actions build Docker images

## 项目简介

 > 此项目是为了在 **[Raspberry Pi4](https://www.raspberrypi.com/)** 上运行Gitlab 而创建。

> ⚠️ **重要更新（2025+）**：
> - **GitLab 官方从 18.1 版本开始已原生支持 ARM64 架构** 🎉
> - 如果你需要 **GitLab 18.0 或更新版本**，建议直接使用官方镜像：`gitlab/gitlab-ee:latest`
> - 本项目主要为 **GitLab 18.0 及更早版本** 提供 ARM64 支持
> - 官方镜像地址：https://hub.docker.com/r/gitlab/gitlab-ee

该项目旨在为 **GitLab EE** 提供 **ARM64 架构**的 Docker 镜像构建支持。通过自动化脚本和 GitHub Actions 工作流，用户可以轻松地构建、管理和发布适用于 ARM64 的 GitLab EE 镜像。

主要功能包括：
- 自动检测最新的 GitLab EE 版本。
- 构建并推送 ARM64 架构的 Docker 镜像。
- 使用 GitHub Actions 实现持续集成和自动化构建。
- 提供 Docker Compose 示例，方便用户快速部署。

---

## 版本支持说明

| GitLab 版本 | ARM64 支持 | 推荐镜像 |
|------------|-----------|---------|
| 18.x | ✅ 官方支持 | `gitlab/gitlab-ee:latest` |
| 17.x | ⚠️ 本项目| `gsdukbh/gitlab-ee:17.x.x-ee.0` |
| 16.x | ⚠️ 本项目 | `gsdukbh/gitlab-ee-arm64:16.x.x-ee.0` |
| 15.x 及更早 | ⚠️ 本项目 | `gsdukbh/gitlab-ee-arm64:15.x.x-ee.0` |

**注意**：对于 GitLab 18.0+，我们强烈建议使用官方镜像以获得更好的支持和更新。

---

## 学习指南

### 1. 项目结构

- **脚本文件**
  - `build-tag.sh`：用于构建指定版本的 Docker 镜像。
  - `build.sh`：检查缺失的标签并构建相应的镜像。
  - `check-version.sh`：从 GitLab 官方获取最新版本信息。
  - `test.sh`：用于测试环境变量的简单脚本。

- **配置文件**
  - `.github/workflows/build.yml`：GitHub Actions 工作流，用于手动触发构建。
  - `.github/workflows/blank.yml`：定时任务工作流，用于检查和构建新版本。

- **数据文件**
  - `version`：记录所有已构建的版本。
  - `latest`：记录最新的版本号。

- **文档**
  - `README.md`：项目的使用说明和 Docker Compose 示例。
  - `LEARN.md`：学习指南和项目概述。

---

### 2. 如何使用

1. **构建镜像**
   - 手动运行 `build-tag.sh` 或通过 GitHub Actions 触发构建。
   - 构建完成后，镜像会被推送到 Docker Hub。

2. **自动化构建**
   - 配置 GitHub Secrets：
     - `DOCKER_PASSWORD`：Docker Hub 密码。
     - `MAIL`：Git 提交时的邮箱。
     - `MY_NAME`：Git 提交时的用户名。
   - 使用 `build.yml` 手动触发构建，或通过 `blank.yml` 定时检查新版本。

3. **部署**
   - 使用 `README.md` 中的 Docker Compose 示例快速启动 GitLab EE 服务。

---

### 3. 学习重点

- **GitHub Actions**：学习如何配置和使用工作流实现自动化构建。
- **Docker 多架构支持**：了解如何使用 `docker buildx` 构建 ARM64 镜像。
- **版本管理**：通过脚本自动检测和管理版本。
- **持续集成**：结合 Git 和 Docker 实现完整的 CI/CD 流程。
- **bash 脚本编程**:  
    学习如何编写高效的 Bash 脚本以实现自动化任务。通过本项目中的脚本示例，您可以掌握以下技能：  
    - 使用条件语句和循环结构处理复杂逻辑。  
    - 通过 `curl` 或 `wget` 获取远程数据，例如从 GitLab 官方获取最新版本信息。  
    - 使用正则表达式和文本处理工具（如 `grep`、`awk` 和 `sed`）解析和处理数据。  
    - 编写模块化脚本，提高代码的可读性和可维护性。  
    - 使用环境变量和参数化脚本增强脚本的灵活性和通用性。  
    - 通过日志记录和错误处理提高脚本的可靠性。  

    通过这些脚本编程实践，您将能够更高效地完成自动化构建、版本管理和部署任务。
---

通过本项目，您可以深入学习如何构建和管理适用于 ARM64 架构的 Docker 镜像，并掌握自动化构建和部署的最佳实践。

