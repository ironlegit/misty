# Misty

A Mistral Vibe Agent Setup using Docker Agent.

## Prerequisites

* Docker Buildx
* Setup gVisor
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
