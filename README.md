# Misty

A Mistral Vibe Agent Setup using Docker Agent.

## Prerequisites

### Install Docker Agent

**TO-RM**

```bash
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m); case "$ARCH" in x86_64) ARCH=amd64;; aarch64) ARCH=arm64;; esac
curl -L "https://github.com/docker/docker-agent/releases/latest/download/docker-agent-${OS}-${ARCH}" -o docker-agent
chmod +x docker-agent
sudo mv docker-agent /usr/local/bin/
docker-agent version
```

### Setup gVisor

1. [Install gVisor](https://gvisor.dev/docs/user_guide/install/)
2. [Configure Docker](https://gvisor.dev/docs/user_guide/quick_start/docker/)

## Setup secrets

Create a `.env`
```bash
MISTRAL_API_KEY=<KEY>
GITHUB_PERSONAL_ACCESS_TOKEN=<PAT>
TELEMETRY_ENABLED=false
```

Create a fine-grained token for specific Github repos with limited permissions:

* Contents: Read and Write
* Pull requests: Read and Write
* Issues: Read-only

## Run Docker Agent

**Update**

```bash
docker-agent run --env-from-file .env
```
