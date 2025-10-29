# Docker Setup Guide

## Overview

This document provides instructions for building, running, and managing the React Chatbot application using Docker.

## Prerequisites

- Docker installed (version 20.10 or higher)
- Docker Compose installed (version 1.29 or higher)
- For Windows users: Docker Desktop with WSL 2 backend recommended

## Quick Start

### Using Docker Compose (Recommended)

1. **Build and run the application:**

```bash
docker-compose up -d
```

2. **Access the chatbot:**

Open your browser and navigate to: `http://localhost:3000`

3. **View logs:**

```bash
docker-compose logs -f chatbot
```

4. **Stop the application:**

```bash
docker-compose down
```

## Building Manually with Docker

### Build the Docker Image

```bash
docker build -t react-chatbot:latest .
```

### Run the Container

```bash
docker run -d -p 3000:3000 --name chatbot react-chatbot:latest
```

### Run with Environment Variables

```bash
docker run -d -p 3000:3000 \
  --env NODE_ENV=production \
  --name chatbot \
  react-chatbot:latest
```

## Docker Compose Commands

### Start Services

```bash
# Start in detached mode (background)
docker-compose up -d

# Start and view logs
docker-compose up
```

### Stop Services

```bash
# Stop without removing
docker-compose stop

# Stop and remove containers
docker-compose down

# Remove volumes as well
docker-compose down -v
```

### View Logs

```bash
# View logs from all services
docker-compose logs

# Follow logs in real-time
docker-compose logs -f

# View logs for specific service
docker-compose logs -f chatbot

# View last 100 lines
docker-compose logs --tail 100
```

### Rebuild Services

```bash
# Rebuild images (useful after code changes)
docker-compose build --no-cache

# Rebuild and start
docker-compose up --build -d
```

## Docker Configuration Files

### Dockerfile

Multi-stage build process:
- **Builder Stage**: Compiles the React app using Node 18
- **Production Stage**: Serves the built app using a lightweight server

Key features:
- Alpine Linux for smaller image size
- Production-ready Node.js server
- Health checks configured

### docker-compose.yml

Services defined:
- **chatbot**: Main application service
  - Port: 3000
  - Health checks enabled
  - Auto-restart policy
  - Network isolation

### .dockerignore

Excludes unnecessary files from Docker build context:
- node_modules
- dist
- .git
- .env files

## Container Details

### Image Information

- **Base Image**: `node:18-alpine` (smallest Node.js image)
- **Size**: ~120-150 MB (approximate)
- **Working Directory**: `/app`

### Port Mapping

- **Container Port**: 3000
- **Host Port**: 3000
- **Access URL**: `http://localhost:3000`

### Environment Variables

```
NODE_ENV=production
```

## Health Checks

The container includes a health check that:
- Tests the endpoint every 30 seconds
- Times out after 10 seconds
- Retries 3 times before marking as unhealthy
- Waits 40 seconds before first check (startup period)

View health status:

```bash
docker ps --format "table {{.Names}}\t{{.Status}}"
```

## Troubleshooting

### Port Already in Use

If port 3000 is already in use:

```bash
# Option 1: Use a different port
docker run -d -p 8080:3000 --name chatbot react-chatbot:latest

# Option 2: Kill the existing container
docker stop chatbot
docker rm chatbot
```

### Container Won't Start

Check logs:

```bash
docker logs chatbot
```

### Memory Issues

Limit memory usage:

```bash
docker run -d -p 3000:3000 -m 512m --name chatbot react-chatbot:latest
```

### Rebuild After Code Changes

```bash
# Stop and remove
docker-compose down

# Rebuild and start
docker-compose up --build -d
```

### Access Container Shell

```bash
docker exec -it chatbot sh
```

## Production Deployment

### Using Docker Registry

1. **Tag image:**

```bash
docker tag react-chatbot:latest yourusername/react-chatbot:latest
```

2. **Push to registry:**

```bash
docker push yourusername/react-chatbot:latest
```

3. **Pull on server:**

```bash
docker pull yourusername/react-chatbot:latest
docker run -d -p 3000:3000 yourusername/react-chatbot:latest
```

### Docker Security Best Practices

1. **Run as non-root user** (already implemented in Alpine)
2. **Use read-only filesystems** where possible
3. **Limit resources** (CPU and memory)
4. **Use environment variables** for sensitive data
5. **Scan images** for vulnerabilities:

```bash
docker scan react-chatbot:latest
```

## Performance Optimization

### Build Optimization

1. **Layer caching**: Dockerfile is optimized for Docker's layer caching
2. **Multi-stage build**: Reduces final image size by excluding build dependencies
3. **Alpine Linux**: Smaller base image than default Node image

### Image Size Comparison

- Default Node.js: ~910 MB
- Node.js Alpine: ~170 MB
- React Chatbot build: ~120-150 MB

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Docker Build and Push

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: docker/setup-buildx-action@v1
      - uses: docker/build-push-action@v2
        with:
          push: true
          tags: myrepo/react-chatbot:latest
```

### GitLab CI Example

```yaml
docker_build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker build -t react-chatbot:latest .
    - docker push react-chatbot:latest
```

## Useful Docker Commands Reference

```bash
# List running containers
docker ps

# List all containers
docker ps -a

# View container details
docker inspect chatbot

# Remove image
docker rmi react-chatbot:latest

# Prune unused images and containers
docker system prune

# View image layers
docker history react-chatbot:latest

# Compare image sizes
docker images
```

## Network Configuration

### Exposing to Other Services

```bash
# Using Docker Compose with shared network
docker-compose up -d

# Other containers can access via: http://chatbot:3000
```

### Custom Network

```bash
docker network create chatbot-net
docker run -d --network chatbot-net -p 3000:3000 --name chatbot react-chatbot:latest
```

## Support and Additional Resources

- [Docker Official Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [Node.js Docker Best Practices](https://nodejs.org/en/docs/guides/nodejs-docker-webapp/)
- [Alpine Linux](https://alpinelinux.org/)

---

For more information about the React Chatbot itself, see the main [README.md](./README.md).
