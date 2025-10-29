# Docker Deployment Guide

## Quick Reference

### Production Deployment

```bash
# Build image
docker build -t react-chatbot:latest .

# Run container
docker run -d -p 3000:3000 --name chatbot react-chatbot:latest

# Or with Docker Compose
docker-compose up -d
```

### Development with Docker

```bash
# Start dev environment with hot reload
docker-compose -f docker-compose.dev.yml up

# Access at http://localhost:5173
```

## Files Overview

| File | Purpose |
|------|---------|
| `Dockerfile` | Production build with multi-stage compilation |
| `Dockerfile.dev` | Development build with HMR support |
| `docker-compose.yml` | Production orchestration |
| `docker-compose.dev.yml` | Development orchestration with hot reload |
| `.dockerignore` | Files to exclude from Docker build |
| `k8s-deployment.yaml` | Kubernetes deployment configuration |

## Directory Structure

```
chatbot devops/
├── Dockerfile              # Production Dockerfile
├── Dockerfile.dev          # Development Dockerfile
├── docker-compose.yml      # Production compose file
├── docker-compose.dev.yml  # Development compose file
├── .dockerignore          # Files to exclude
├── k8s-deployment.yaml    # Kubernetes config
├── DOCKER.md              # Detailed Docker guide
├── src/
│   ├── Chatbot.tsx
│   ├── Chatbot.css
│   ├── App.tsx
│   └── ...
├── package.json
└── ...
```

## Common Docker Commands

### Container Management

```bash
# List running containers
docker ps

# Stop container
docker stop chatbot

# Start container
docker start chatbot

# Remove container
docker rm chatbot

# View logs
docker logs chatbot
docker logs -f chatbot  # Follow logs
```

### Image Management

```bash
# List images
docker images

# Remove image
docker rmi react-chatbot:latest

# Inspect image
docker inspect react-chatbot:latest

# View image history
docker history react-chatbot:latest
```

### Docker Compose

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# Rebuild images
docker-compose build --no-cache

# View logs
docker-compose logs -f

# Execute command in container
docker-compose exec chatbot sh
```

## Environment Setup

### Production (.env)

```
NODE_ENV=production
VITE_APP_TITLE=React Chatbot
```

### Development (.env.dev)

```
NODE_ENV=development
VITE_INLINE=true
```

## Port Configuration

| Environment | Container Port | Host Port | URL |
|------------|----------------|-----------|-----|
| Production | 3000 | 3000 | http://localhost:3000 |
| Development | 5173 | 5173 | http://localhost:5173 |

## Building and Running

### Step 1: Build the Docker Image

```bash
docker build -t react-chatbot:latest .
```

### Step 2: Run the Container

**Option A: Direct Docker**

```bash
docker run -d \
  -p 3000:3000 \
  --name chatbot \
  --restart unless-stopped \
  react-chatbot:latest
```

**Option B: Docker Compose (Recommended)**

```bash
docker-compose up -d
```

### Step 3: Verify It's Running

```bash
# Check container status
docker ps

# Check logs
docker logs chatbot

# Test the application
curl http://localhost:3000
```

### Step 4: Stop the Container

```bash
# Stop gracefully
docker stop chatbot

# Or with Compose
docker-compose down
```

## Development Workflow

### Option 1: Docker Container with Hot Reload

```bash
# Start development environment
docker-compose -f docker-compose.dev.yml up

# Modify source files - changes update automatically
# Access at http://localhost:5173
```

### Option 2: Local Development (Without Docker)

```bash
npm install
npm run dev
```

## Multi-Environment Setup

### Production

```bash
docker-compose -f docker-compose.yml up -d
```

### Development

```bash
docker-compose -f docker-compose.dev.yml up
```

### Both Running Simultaneously

```bash
# Terminal 1: Production
docker-compose up -d

# Terminal 2: Development
docker-compose -f docker-compose.dev.yml up
```

## Advanced Configurations

### Custom Port

```bash
# Change port in docker-compose.yml
ports:
  - "8080:3000"  # Maps host:8080 to container:3000

# Or with direct docker
docker run -d -p 8080:3000 react-chatbot:latest
```

### Resource Limits

```bash
# Limit CPU and memory
docker run -d \
  -p 3000:3000 \
  -m 512m \
  --cpus="1" \
  react-chatbot:latest
```

### Environment Variables

```bash
docker run -d \
  -p 3000:3000 \
  -e NODE_ENV=production \
  -e VITE_APP_TITLE="My Chatbot" \
  react-chatbot:latest
```

## Troubleshooting

### Port Already in Use

```bash
# Find process using port 3000
lsof -i :3000  # Linux/Mac
netstat -ano | findstr :3000  # Windows

# Kill process or use different port
docker run -d -p 8080:3000 react-chatbot:latest
```

### Container Exits Immediately

```bash
# Check logs
docker logs chatbot

# Run interactively to see errors
docker run -it react-chatbot:latest
```

### Rebuild After Changes

```bash
# Stop old container
docker-compose down

# Rebuild and start
docker-compose up --build -d
```

### Access Container Shell

```bash
docker exec -it chatbot sh
```

## Performance Tips

1. **Use Alpine Linux**: Already used in Dockerfile (smaller image)
2. **Multi-stage builds**: Already used (excludes build tools)
3. **Layer caching**: Order dependencies before source code
4. **Health checks**: Monitor container health
5. **Resource limits**: Prevent resource exhaustion

## Security Best Practices

1. ✅ Use specific base image versions
2. ✅ Run as non-root (Alpine default)
3. ✅ Set resource limits
4. ✅ Use health checks
5. ✅ Exclude sensitive files with .dockerignore
6. ✅ Scan images for vulnerabilities

```bash
docker scan react-chatbot:latest
```

## CI/CD Integration

### GitHub Actions

```yaml
name: Build and Push Docker Image
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: docker/setup-buildx-action@v1
      - uses: docker/build-push-action@v2
        with:
          push: true
          tags: registry/react-chatbot:latest
```

## Kubernetes Deployment

Deploy using the provided `k8s-deployment.yaml`:

```bash
# Apply deployment
kubectl apply -f k8s-deployment.yaml

# Check status
kubectl get pods
kubectl get svc

# View logs
kubectl logs -f deployment/react-chatbot
```

## Cleanup

### Remove Everything

```bash
# Stop and remove containers
docker-compose down -v

# Remove all stopped containers
docker container prune

# Remove dangling images
docker image prune

# Remove everything unused
docker system prune -a --volumes
```

## Next Steps

1. Test locally: `docker-compose up -d`
2. Access application: `http://localhost:3000`
3. Deploy to production registry
4. Configure CI/CD pipeline
5. Monitor container health
6. Scale with Kubernetes if needed

---

For detailed information, see [DOCKER.md](./DOCKER.md).
