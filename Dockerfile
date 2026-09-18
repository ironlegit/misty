FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates git openssh-client curl \
  && rm -rf /var/lib/apt/lists/*

# Pin a real release version — don't float latest
ARG DOCKER_AGENT_VERSION=v1.141.0
RUN curl -fsSL "https://github.com/docker/docker-agent/releases/download/${DOCKER_AGENT_VERSION}/docker-agent-linux-amd64" \
  -o /usr/local/bin/docker-agent \
  && chmod +x /usr/local/bin/docker-agent

# Create necessary folders for agent user
RUN useradd --create-home --uid 1000 agent
RUN mkdir -p /home/agent/.cagent /home/agent/.config \
  && chown -R agent:agent /home/agent
USER agent
WORKDIR /workspace

ENTRYPOINT ["docker-agent"]
