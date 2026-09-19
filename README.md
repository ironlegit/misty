# Misty

A containerized [Docker Agent](https://github.com/docker/docker-agent) setup for running an autonomous coding agent against a Git repository, powered by the Mistral API. It's built to run safely inside a VM without requiring nested virtualization. Isolation comes from gVisor and an egress-restricted forward proxy instead of a hardware-virtualized sandbox.

## Architecture

```mermaid
graph TB
    subgraph HOST["Host OS"]
        subgraph VM["Guest VM (VMware Workstation)"]
            REPO[("repo-x<br/>bind-mounted")]

            subgraph STACK["Docker Compose stack"]
                AGENT["<b>agent</b> container<br/>gVisor (runsc) sandbox<br/><br/>docker-agent · git · shell<br/>non-root · read-only fs<br/>cpu/mem limits"]
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

The agent has no direct route to the internet — the `egress` network is internal-only, so every outbound request is forced through `proxy`, which only allows traffic to Mistral and GitHub.

## Prerequisites

- Mistral API key
- GitHub personal access token (see [GitHub token](#github-token))
- Docker with Buildx
- gVisor, installed and configured for Docker:
  1. [Install gVisor](https://gvisor.dev/docs/user_guide/install/)
  2. [Configure the Docker runtime](https://gvisor.dev/docs/user_guide/quick_start/docker/)

## Setup

### Secrets

Create a `.env` file in the project root:

```bash
# API keys
MISTRAL_API_KEY=<key>
GITHUB_PERSONAL_ACCESS_TOKEN=<pat>

# Target repository (absolute path on the host)
REPO_PATH=/absolute/path/to/target-repo

# Docker Agent
TELEMETRY_ENABLED=false

# Git identity, so agent commits are distinguishable from your own
GIT_AUTHOR_NAME=misty[bot]
GIT_AUTHOR_EMAIL=misty-bot@users.noreply.github.com
GIT_COMMITTER_NAME=misty[bot]
GIT_COMMITTER_EMAIL=misty-bot@users.noreply.github.com
```

### GitHub token

Create a fine-grained personal access token, scoped to the specific repositories this agent should touch:

| Permission | Access |
| --- | --- |
| Contents | Read and write |
| Pull requests | Read and write |
| Issues | Read-only |

### Target repository

Before running the agent:

1. Make sure the repo is clean, with no uncommitted changes — the agent works directly against your checked-out working copy, not a snapshot.
2. Point the remote at HTTPS with the token embedded, so the agent can push without an interactive credential prompt:

   ```bash
   git remote set-url origin "https://x-access-token:${GITHUB_PERSONAL_ACCESS_TOKEN}@github.com/<user>/<repo>.git"
   ```

## Usage

Start the agent (opens the interactive dashboard):

```bash
docker compose run --rm agent run
```

Rebuild and reset (clears session state and the first-run marker):

```bash
docker compose down -v
docker compose build agent
docker compose run --rm agent run
```
