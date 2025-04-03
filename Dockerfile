# Base image
FROM node:20-slim

# Metadata labels
LABEL maintainer="Britehouse Mobility DevOps <devops@britehousemobility.com>"
LABEL version="1.0"
LABEL description="CodePush Server Standalone CLI"
LABEL org.opencontainers.image.source="https://github.com/microsoft/code-push-server"

# Environment variables
ENV access_key=${access_key:-"your-access-key"}
ENV app_name=${app_name:-"your-app"}
ENV command=${command:-"release"}
ENV deployment_name=${deployment_name:-"Staging"}
ENV server_url=${server_url:-"https://appcenter.ms"}
ENV target_version=${target_version:-"1.0.0"}
ENV NODE_ENV=development

# Create a non-root user
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -r codepush && useradd -r -g codepush codepush \
    && mkdir -p /data

# Set up volume for data persistence
VOLUME ["/data"]
WORKDIR /opt/

# Clone and set up code-push-server in one layer to reduce image size
RUN git clone --depth 1 https://github.com/microsoft/code-push-server.git

WORKDIR /opt/code-push-server/cli

RUN npm install --include=dev \ 
    && npm run build \
    && npm install -g

# Runtime command
ENTRYPOINT ["sh", "-c"]
CMD ["code-push-standalone login --accessKey ${access_key} ${server_url} && code-push-standalone ${command} ${app_name} /data ${target_version} -d ${deployment_name}"]
