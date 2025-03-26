# CodePush Server Standalone CLI

This Docker container provides a standalone CLI for interacting with a CodePush server, allowing you to easily release prebuilt React Native applications to a CodePush server instance.

## Overview

This container wraps the [Microsoft CodePush Server](https://github.com/microsoft/code-push-server) CLI tools to simplify the process of releasing updates to your applications using CodePush. It's designed to be used as part of a CI/CD pipeline or as a standalone tool for releasing updates.

## Prerequisites

- Docker installed on your system
- Access to a CodePush server instance
- An access key for your CodePush server
- Your application bundle prepared in a directory

## Building the Container

To build the container image, run:

```bash
docker build -t codepush-cli:latest .
```

## Usage

The container is configured with several environment variables that control its behavior:

| Variable | Description | Default |
|----------|-------------|---------|
| `access_key` | Your CodePush server access key | "your-access-key" |
| `app_name` | The name of your application | "your-app" |
| `command` | The CodePush command to run | "release" |
| `server_url` | URL of your CodePush server | "https://appcenter.ms" |
| `target_version` | Target version of your app | "1.0.0" |

### Releasing an Update

To release an update to your CodePush server, mount your application bundle directory to `/data` in the container and set the appropriate environment variables:

```bash
docker run --rm \
  -v /path/to/your/app/bundle:/data \
  -e access_key="your-access-key" \
  -e app_name="YourApp" \
  -e server_url="https://your-codepush-server.com" \
  -e target_version="1.2.0" \
  codepush-cli:latest
```

### Advanced Usage

#### Specifying a Different Command

By default, the container runs the `release` command. You can specify a different command using the `command` environment variable:

```bash
docker run --rm \
  -v /path/to/your/app/bundle:/data \
  -e access_key="your-access-key" \
  -e app_name="YourApp" \
  -e command="promote" \
  -e server_url="https://your-codepush-server.com" \
  codepush-cli:latest
```

#### Using with CI/CD Systems

This container is ideal for integration with CI/CD pipelines. For example, with GitHub Actions:

```yaml
steps:
  - name: Release to CodePush
    run: |
      docker run --rm \
        -v ${{ github.workspace }}/dist:/data \
        -e access_key="${{ secrets.CODEPUSH_ACCESS_KEY }}" \
        -e app_name="${{ env.APP_NAME }}" \
        -e server_url="${{ env.CODEPUSH_SERVER_URL }}" \
        -e target_version="${{ env.APP_VERSION }}" \
        codepush-cli:latest
```

#### CI/CD Image Accessibility Caveat

If you want to include this container as part of a CI/CD pipeline, you will need to make the container image accessible to the pipeline. This can be done by:

1. Pushing the built container to a public container registry (like Docker Hub, GitHub Container Registry, etc.)
2. Using a privately hosted build agent or runner where this image has either been pre-built
3. Using a private container registry that your CI/CD system has access to pull from

Example of pushing to a container registry:

```bash
# Build and tag the image
docker build -t yourusername/codepush-cli:latest .

# Push to Docker Hub
docker push yourusername/codepush-cli:latest

# For GitHub Container Registry
docker build -t ghcr.io/yourusername/codepush-cli:latest .
docker push ghcr.io/yourusername/codepush-cli:latest
```

Then update your CI/CD configuration to use the registry version:

```yaml
steps:
  - name: Release to CodePush
    run: |
      docker run --rm \
        -v ${{ github.workspace }}/dist:/data \
        -e access_key="${{ secrets.CODEPUSH_ACCESS_KEY }}" \
        -e app_name="${{ env.APP_NAME }}" \
        -e server_url="${{ env.CODEPUSH_SERVER_URL }}" \
        -e target_version="${{ env.APP_VERSION }}" \
        ghcr.io/yourusername/codepush-cli:latest
```

## Troubleshooting

### Permissions Issues

If you encounter permissions issues with the mounted volume, ensure that the directory you're mounting has appropriate permissions for the container's `codepush` user (UID 999).

### Connection Issues

If you're having trouble connecting to your CodePush server:
1. Verify that the server URL is correct
2. Check that your access key is valid
3. Ensure your network allows connections to the server

## License

This project is based on Microsoft's Code Push Server which is licensed under the MIT License.

## Maintainer

Britehouse Mobility DevOps