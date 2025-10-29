# Docker Host Configuration

## Local Development Host

### Using Docker Desktop

1. **Windows/Mac**: Docker Desktop automatically configures localhost
2. **Linux**: Use `docker0` bridge network or configure manually

### Network Configuration

```bash
# Check Docker network
docker network ls

# Inspect chatbot network
docker network inspect chatbot-network

# Connect to existing network
docker network connect chatbot-network container_name
```

## Hosting Configurations

### 1. Local Hosting (localhost)

```bash
# Production
docker-compose up -d
# Access: http://localhost:3000

# Development
docker-compose -f docker-compose.dev.yml up
# Access: http://localhost:5173
```

### 2. Network Hosting (Access from other machines)

Edit `docker-compose.yml`:

```yaml
services:
  chatbot:
    ports:
      - "0.0.0.0:3000:3000"  # Listen on all interfaces
```

Then access from any machine:
```
http://<your-machine-ip>:3000
```

### 3. Docker Host Remote Access

```bash
# Get your machine IP
# Windows: ipconfig
# Mac/Linux: ifconfig

# Edit .env or docker-compose.yml
DOCKER_HOST=tcp://your-ip:2375
```

### 4. Reverse Proxy Setup (Nginx)

See `nginx.conf` configuration below.

### 5. Cloud Hosting

See cloud deployment examples below.

## Environment Setup

Create `.env.docker` file:

```env
# Host Configuration
DOCKER_HOST=unix:///var/run/docker.sock
CHATBOT_PORT=3000
CHATBOT_HOST=0.0.0.0

# Application
NODE_ENV=production
VITE_APP_TITLE=React Chatbot

# API Configuration
VITE_API_TIMEOUT=30000
```

Load in docker-compose:

```yaml
env_file:
  - .env.docker
```

## Docker Socket Binding

### Local Socket (Default)
```bash
# Linux/Mac
-v /var/run/docker.sock:/var/run/docker.sock
```

### TCP Socket (Remote)
```bash
# Configure Docker daemon
"hosts": ["unix:///var/run/docker.sock", "tcp://0.0.0.0:2375"]
```

## Port Configuration

### Available Ports

```
3000   - Production app (http)
5173   - Development (Vite)
8000   - Alternative production
8080   - Nginx reverse proxy
9000   - Docker API
```

### Change Port

Edit `docker-compose.yml`:

```yaml
ports:
  - "${CHATBOT_PORT}:3000"  # Use env variable
  # or
  - "8080:3000"  # Direct mapping
```

## Host Firewall Configuration

### Windows Firewall

```powershell
# Allow Docker port
netsh advfirewall firewall add rule name="Docker Chatbot" dir=in action=allow protocol=tcp localport=3000

# Remove rule
netsh advfirewall firewall delete rule name="Docker Chatbot"
```

### Linux Firewall (UFW)

```bash
# Allow port
sudo ufw allow 3000/tcp

# Check status
sudo ufw status
```

### macOS Firewall

Use System Preferences → Security & Privacy → Firewall

## Docker Daemon Configuration

### daemon.json Location

**Windows**: `%ProgramData%\docker\config\daemon.json`
**Mac**: `~/.docker/daemon.json`
**Linux**: `/etc/docker/daemon.json`

### Configuration Example

```json
{
  "debug": false,
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2",
  "hosts": [
    "unix:///var/run/docker.sock",
    "tcp://0.0.0.0:2375"
  ],
  "insecure-registries": []
}
```

## Volume Mounting

### Local Volume

```yaml
volumes:
  - ./src:/app/src          # Source code
  - ./dist:/app/dist        # Build output
  - app-node-modules:/app/node_modules  # Persistent modules
```

### Named Volume

```bash
docker volume create chatbot-data
docker volume ls
docker volume inspect chatbot-data
```

## Health Check Configuration

Current health check in docker-compose.yml:

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:3000"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

### Custom Health Check

```yaml
healthcheck:
  test: 
    - CMD
    - sh
    - -c
    - curl -f http://localhost:3000/ || exit 1
```

## Networking Setup

### Bridge Network (Default)

```yaml
networks:
  chatbot-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

### Custom Network

```bash
docker network create chatbot-net --driver bridge

docker run -d \
  --network chatbot-net \
  -p 3000:3000 \
  react-chatbot:latest
```

### Inter-container Communication

```yaml
services:
  chatbot:
    networks:
      - chatbot-network
    container_name: chatbot

  # Other services can access via: http://chatbot:3000
```

## Resource Limits

### CPU Limits

```yaml
resources:
  limits:
    cpus: '1'
    memory: 512M
  reservations:
    cpus: '0.5'
    memory: 256M
```

### Memory Limits

```bash
docker run -d \
  -m 512m \
  --memory-swap 1g \
  react-chatbot:latest
```

## Logging Configuration

### Docker Compose Logging

```yaml
services:
  chatbot:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
        labels: "chatbot"
```

### View Logs

```bash
docker logs chatbot
docker logs -f chatbot              # Follow
docker logs --tail 100 chatbot      # Last 100 lines
docker logs --since 2h chatbot      # Last 2 hours
```

## Restart Policy

```yaml
restart_policy:
  condition: on-failure
  delay: 5s
  max_attempts: 3
  window: 120s
```

Options:
- `no` - Do not restart
- `always` - Always restart
- `unless-stopped` - Restart unless explicitly stopped
- `on-failure` - Restart on failure

## Security Configuration

### User Permission

```dockerfile
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001
USER nodejs
```

### Read-only Filesystem

```yaml
read_only: true
tmpfs:
  - /tmp
  - /app/.next
```

### Network Security

```yaml
cap_drop:
  - ALL
cap_add:
  - NET_BIND_SERVICE
```

## Docker Host Monitoring

### Check Host Status

```bash
# System info
docker info

# Container stats
docker stats

# Specific container
docker stats chatbot

# Watch in real-time
docker stats --no-stream=false
```

### Resource Usage

```bash
# CPU and Memory
docker ps --format "table {{.Container}}\t{{.CPU}}\t{{.MemUsage}}"

# Disk usage
docker system df
```

## Host Backup Configuration

### Backup Volumes

```bash
# Backup named volume
docker run --rm \
  -v chatbot-data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/chatbot-data.tar.gz -C /data .

# Restore
docker run --rm \
  -v chatbot-data:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/chatbot-data.tar.gz -C /data
```

### Backup Configuration

```bash
# Backup docker-compose.yml and .env
tar czf chatbot-backup.tar.gz \
  docker-compose.yml \
  docker-compose.dev.yml \
  .dockerignore \
  .env
```

---

For production hosting, see cloud deployment files and reverse proxy configuration.
