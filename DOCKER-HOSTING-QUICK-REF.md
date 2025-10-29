# Docker & Hosting Configuration - Quick Reference

## 📋 Quick Command Reference

### Start Services

```bash
# Production (with Nginx reverse proxy)
docker-compose -f docker-compose.prod.yml up -d

# Development (with hot reload)
docker-compose -f docker-compose.dev.yml up

# With SSL/HTTPS
docker-compose -f docker-compose.ssl.yml --profile ssl up -d
```

### View Status

```bash
# List running containers
docker ps

# View logs
docker logs -f react-chatbot

# Check health
docker ps --format "table {{.Names}}\t{{.Status}}"

# Resource usage
docker stats
```

### Stop Services

```bash
# Stop all services
docker-compose down

# Remove volumes too
docker-compose down -v

# Remove images
docker-compose down --rmi all
```

---

## 🌐 Access Points

| Service | URL | Port | Environment |
|---------|-----|------|-------------|
| Application | http://localhost:3000 | 3000 | Production |
| Development | http://localhost:5173 | 5173 | Dev (Hot reload) |
| Nginx Proxy | http://localhost:80 | 80 | Production with proxy |
| HTTPS/SSL | https://your-domain.com | 443 | Production with SSL |

---

## 📁 Configuration Files

| File | Purpose | Usage |
|------|---------|-------|
| `docker-compose.yml` | Basic production | `docker-compose up -d` |
| `docker-compose.dev.yml` | Development with HMR | `docker-compose -f docker-compose.dev.yml up` |
| `docker-compose.prod.yml` | Production with Nginx | `docker-compose -f docker-compose.prod.yml up -d` |
| `docker-compose.ssl.yml` | HTTPS/SSL setup | `docker-compose -f docker-compose.ssl.yml up -d` |
| `Dockerfile` | Production build | Used by compose |
| `Dockerfile.dev` | Development build | Used by dev compose |
| `nginx.conf` | Nginx proxy config | For `docker-compose.prod.yml` |
| `.env.docker.example` | Environment template | Copy to `.env` |
| `.dockerignore` | Build exclusions | Reduces image size |

---

## 🚀 Deployment Scenarios

### Scenario 1: Local Development

```bash
# Start dev environment with hot reload
docker-compose -f docker-compose.dev.yml up

# Access at http://localhost:5173
# Code changes reload automatically
```

### Scenario 2: Local Testing (Production)

```bash
# Start production setup
docker-compose up -d

# Access at http://localhost:3000
# Or via Nginx: http://localhost:80
```

### Scenario 3: Production with SSL

```bash
# Export environment variables
export CERTBOT_EMAIL=admin@your-domain.com
export CERTBOT_DOMAIN=your-domain.com
export NGINX_HOST=your-domain.com

# Start with SSL
docker-compose -f docker-compose.ssl.yml --profile ssl up -d

# Access at https://your-domain.com
```

### Scenario 4: Production with Reverse Proxy

```bash
# Start production with Nginx proxy
docker-compose -f docker-compose.prod.yml up -d

# Access through Nginx on port 80
# curl http://localhost:80
```

---

## 🔧 Common Tasks

### View Logs

```bash
# All services
docker-compose logs

# Specific service
docker-compose logs chatbot
docker-compose logs nginx

# Follow logs
docker-compose logs -f chatbot

# Last N lines
docker-compose logs --tail 50
```

### Execute Commands in Container

```bash
# Get shell access
docker exec -it react-chatbot sh

# Run command
docker exec react-chatbot npm run build

# View files
docker exec react-chatbot ls -la
```

### Rebuild After Changes

```bash
# Rebuild images
docker-compose build

# Rebuild specific service
docker-compose build chatbot

# Rebuild without cache
docker-compose build --no-cache
```

### Network Debugging

```bash
# List networks
docker network ls

# Inspect network
docker network inspect chatbot-network

# Check container IP
docker inspect react-chatbot | grep IPAddress
```

---

## 📊 Container Management

### Resource Limits

Set in docker-compose files:

```yaml
resources:
  limits:
    cpus: '1'
    memory: 512M
  reservations:
    cpus: '0.5'
    memory: 256M
```

### Monitor Resources

```bash
# Real-time stats
docker stats

# Container details
docker inspect react-chatbot

# View logs and resource usage
docker logs -f react-chatbot &
docker stats react-chatbot
```

---

## 🌍 Network Access

### Local Network Only (Default)

```bash
# App only accessible from localhost
# URL: http://localhost:3000
```

### Network Access (All Interfaces)

Edit docker-compose to expose on all interfaces:

```yaml
ports:
  - "0.0.0.0:3000:3000"
```

Then access from:
- Same machine: `http://localhost:3000`
- Other machines: `http://<your-ip>:3000`

### Get Your IP Address

**Windows:**
```powershell
ipconfig
# Look for IPv4 Address
```

**Mac/Linux:**
```bash
ifconfig
# Look for inet address
```

---

## 🔒 Security Setup

### SSL Certificate Generation

```bash
# Self-signed (development)
openssl req -x509 -newkey rsa:2048 -keyout ssl/key.pem -out ssl/cert.pem -days 365 -nodes

# Let's Encrypt (production)
docker-compose -f docker-compose.ssl.yml --profile ssl up -d
```

### Security Headers

Nginx automatically adds:
- Strict-Transport-Security
- X-Frame-Options
- X-Content-Type-Options
- X-XSS-Protection

---

## 📈 Scaling & Load Balancing

### Docker Compose Scaling

```bash
# Scale service to 3 instances
docker-compose up -d --scale chatbot=3

# Note: Requires load balancer configuration
```

### Kubernetes Scaling

```bash
# Apply k8s deployment (auto-scaling configured)
kubectl apply -f k8s-deployment.yaml

# Check replicas
kubectl get deployments
```

---

## 🧹 Cleanup

### Remove Stopped Containers

```bash
docker container prune
```

### Remove Unused Images

```bash
docker image prune
```

### Remove All Unused Resources

```bash
docker system prune -a --volumes
```

### Full Reset

```bash
docker-compose down -v --rmi all
```

---

## 📚 Environment Configuration

### Create .env File

```bash
# Copy example
cp .env.docker.example .env

# Edit for your setup
nano .env
```

### Load Environment

```bash
# Automatically loaded by docker-compose
docker-compose --env-file .env up -d

# Override specific variables
CHATBOT_PORT=8080 docker-compose up -d
```

---

## 🐛 Troubleshooting

### Port Already in Use

```bash
# Find process
lsof -i :3000

# Use different port
docker run -p 8080:3000 react-chatbot:latest
```

### Container Won't Start

```bash
# Check logs
docker logs react-chatbot

# Run interactively
docker run -it react-chatbot:latest sh
```

### Network Issues

```bash
# Test connectivity
docker exec react-chatbot ping google.com

# Check DNS
docker exec react-chatbot cat /etc/resolv.conf
```

### Disk Space Issues

```bash
# Check usage
docker system df

# Clean up
docker system prune -a

# Remove specific image
docker rmi react-chatbot:latest
```

---

## 📞 Health Checks

### Manual Health Check

```bash
# Test production
curl http://localhost:3000

# Test with Nginx
curl http://localhost:80

# Test HTTPS
curl https://your-domain.com
```

### Container Health Status

```bash
# Check health
docker ps --format "table {{.Names}}\t{{.Status}}"

# Monitor health
watch -n 5 'docker ps --format "table {{.Names}}\t{{.Status}}"'
```

---

## 🚀 Production Checklist

- [ ] Docker image built successfully
- [ ] Environment variables configured
- [ ] Port configuration correct
- [ ] Health checks passing
- [ ] Nginx reverse proxy working
- [ ] SSL/HTTPS certificate installed
- [ ] Monitoring and logging configured
- [ ] Backups enabled
- [ ] Network access configured
- [ ] Performance tested
- [ ] Auto-scaling configured (if needed)

---

## 📖 Documentation Files

- **`DOCKER-INTEGRATION.md`** - Overview and summary
- **`DOCKER.md`** - Comprehensive reference
- **`DOCKER-QUICK-START.md`** - Quick commands
- **`DOCKER-HOST-CONFIG.md`** - Host configuration
- **`SSL-HTTPS-SETUP.md`** - SSL/TLS setup
- **`CLOUD-DEPLOYMENT.md`** - Cloud platform deployment

---

## 🎯 Next Steps

1. **Test Locally**: `docker-compose up -d`
2. **Verify Access**: Visit `http://localhost:3000`
3. **Check Logs**: `docker logs -f react-chatbot`
4. **Configure Domain**: Point domain to server
5. **Setup SSL**: Follow `SSL-HTTPS-SETUP.md`
6. **Deploy to Cloud**: Follow `CLOUD-DEPLOYMENT.md`
7. **Monitor**: Setup logging and monitoring

---

**Your chatbot is ready for production deployment! 🎉**
