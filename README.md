# Misty

A Mistral Vibe Agent Setup using Docker Agent.

# Architecture

```mermaid
graph TB
    subgraph WIN["Host"]
        subgraph VM["VMware Workstation Pro"]
            REPO[("repo-x<br/>bind-mounted")]

            subgraph STACK["Docker Compose stack"]
                AGENT["<b>agent</b> container<br/>🔒 gVisor (runsc) sandbox<br/><br/>docker-agent · git · shell<br/>non-root · read-only fs<br/>cpu/mem limits"]
                PROXY["<b>proxy</b> container<br/>squid forward proxy<br/><br/>allow-list:<br/>*.mistral.ai, github.com"]
            end

            REPO -.->|"/workspace<br/>(bind mount)"| AGENT
        end
    end

    AGENT -->|"HTTPS_PROXY<br/>172.28.1.2:3128<br/>(only route out)"| PROXY
    PROXY -->|allowed| GH[("GitHub<br/>PAT auth")]
    PROXY -->|allowed| MISTRAL[("Mistral API")]

    style AGENT fill:#e8f0fe,stroke:#4285f4,stroke-width:2px
    style PROXY fill:#fef7e0,stroke:#f9ab00,stroke-width:2px
    style REPO fill:#f0f0f0,stroke:#888
    style GH fill:#fff,stroke:#666
    style MISTRAL fill:#fff,stroke:#666
```

## Prerequisites

- Mistral API key
- Github PAT
- Docker Buildx
- Setup gVisor
  1. [Install gVisor](https://gvisor.dev/docs/user_guide/install/)
  2. [Configure Docker](https://gvisor.dev/docs/user_guide/quick_start/docker/)

## Setup secrets

Create a `.env`

```bash
# API Keys
MISTRAL_API_KEY=<KEY>
GITHUB_PERSONAL_ACCESS_TOKEN=<PAT>
# Docker agent stuff
TELEMETRY_ENABLED=false
# Git config to differentiate commits
GIT_AUTHOR_NAME=misty[bot]
GIT_AUTHOR_EMAIL=misty-bot@users.noreply.github.com
GIT_COMMITTER_NAME=misty[bot]
GIT_COMMITTER_EMAIL=misty-bot@users.noreply.github.com

```

Create a fine-grained token for specific Github repos with limited permissions:

- Contents: Read and Write
- Pull requests: Read and Write
- Issues: Read-only

## Prepare target repo

- Make sure repo is clean and has no uncommited changes to avoid git mess.
- Make sure the remote URL includes the PAT and is set to HTTPS.
  - It should look like this:
```bash
git remote set-url origin "https://x-access-token:${GITHUB_PERSONAL_ACCESS_TOKEN}@github.com/<user>/<repo>.git"
``` 

## Run Docker Agent

Start agent:

```bash
docker compose run --rm agent run
```

Restart:

```bash
docker compose down -v
docker compose build agent
docker compose run --rm agent run
```

