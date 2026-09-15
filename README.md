# Install Docker Agent
```bash
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m); case "$ARCH" in x86_64) ARCH=amd64;; aarch64) ARCH=arm64;; esac
curl -L "https://github.com/docker/docker-agent/releases/latest/download/docker-agent-${OS}-${ARCH}" -o docker-agent
chmod +x docker-agent
sudo mv docker-agent /usr/local/bin/
docker-agent version
```
