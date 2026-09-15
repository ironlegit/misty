# Misty

A Mistral Vibe Agent Setup using Docker Agent.

## Install Docker Agent

```bash
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m); case "$ARCH" in x86_64) ARCH=amd64;; aarch64) ARCH=arm64;; esac
curl -L "https://github.com/docker/docker-agent/releases/latest/download/docker-agent-${OS}-${ARCH}" -o docker-agent
chmod +x docker-agent
sudo mv docker-agent /usr/local/bin/
docker-agent version
```

## Setup secrets

Create a `.env`
```bash
MISTRAL_API_KEY=<KEY>
GITHUB_PAT=<PAT>
```

Create a fine-grained token for specific Github repos with limited permissions:

* Contents: Read and Write
* Pull requests: Read and Write
* Issues: Read-only

## Run Docker Agent

```bash
docker-agent run --env-from-file .env
```
