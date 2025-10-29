# SSL/HTTPS Configuration Guide

## Overview

This guide covers setting up HTTPS for your React Chatbot with SSL/TLS certificates.

## Options

1. **Self-Signed Certificate** (Development)
2. **Let's Encrypt** (Free, Production)
3. **Commercial CA** (Premium)
4. **Cloud Provider SSL** (AWS, Google Cloud, Azure)

---

## 1. Self-Signed Certificate (Development)

### Generate Certificate

```bash
# Generate self-signed certificate (valid for 365 days)
openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 365 -nodes

# You'll be prompted for certificate details:
# Country, State, Locality, Organization, etc.
```

### Create SSL Directory

```bash
mkdir -p ssl
mv cert.pem ssl/
mv key.pem ssl/
```

### Update Nginx Configuration

```nginx
server {
    listen 443 ssl http2;
    server_name localhost;

    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;

    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # ... rest of server config
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name localhost;
    return 301 https://$server_name$request_uri;
}
```

### Run with Docker Compose

```bash
docker-compose -f docker-compose.ssl.yml up -d
```

---

## 2. Let's Encrypt (Production)

### Prerequisites

- Valid domain name (not localhost)
- Port 80 and 443 accessible from internet
- Email address for certificate renewal notifications

### Generate Certificate

```bash
# Install Certbot
docker pull certbot/certbot

# Generate certificate
docker run --rm --entrypoint certbot certbot/certbot certonly \
  --standalone \
  -d your-domain.com \
  -d www.your-domain.com \
  --agree-tos \
  --email admin@your-domain.com
```

### Or using Docker Compose

```bash
# Set environment variables
export CERTBOT_EMAIL=admin@your-domain.com
export CERTBOT_DOMAIN=your-domain.com
export NGINX_HOST=your-domain.com

# Run compose with SSL profile
docker-compose -f docker-compose.ssl.yml --profile ssl up -d
```

### Certificate Location

After generation, certificates will be in:
```
./certbot/conf/live/your-domain.com/
  ├── cert.pem (certificate)
  ├── chain.pem (chain)
  ├── fullchain.pem (certificate + chain)
  └── privkey.pem (private key)
```

### Update Nginx Configuration for Let's Encrypt

```nginx
server {
    listen 443 ssl http2;
    server_name your-domain.com www.your-domain.com;

    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;

    # Rest of configuration...
}
```

### Automatic Renewal

Certbot runs automatically with the docker-compose.ssl.yml configuration:

```bash
# Check renewal status
docker exec chatbot-certbot certbot renew --dry-run

# Manual renewal
docker exec chatbot-certbot certbot renew
```

---

## 3. Complete Nginx Configuration with SSL

Create `nginx-ssl.conf`:

```nginx
# Rate limiting
limit_req_zone $binary_remote_addr zone=general:10m rate=10r/s;
limit_req_zone $binary_remote_addr zone=api:10m rate=100r/m;

# Upstream
upstream chatbot_backend {
    server chatbot:3000;
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name _;
    
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
    
    location / {
        return 301 https://$host$request_uri;
    }
}

# HTTPS Server
server {
    listen 443 ssl http2;
    server_name your-domain.com www.your-domain.com;

    # SSL Certificates
    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/your-domain.com/chain.pem;

    # SSL Configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    ssl_session_tickets off;

    # HSTS
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;

    # Security Headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;

    # Gzip Compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1000;
    gzip_types text/plain text/css text/xml text/javascript application/json application/javascript application/xml+rss;

    # Logging
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    # Root location
    location / {
        limit_req zone=general burst=20 nodelay;
        
        proxy_pass http://chatbot_backend;
        proxy_http_version 1.1;
        
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Static files
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        limit_req zone=general burst=50 nodelay;
        
        proxy_pass http://chatbot_backend;
        proxy_cache_valid 200 7d;
        add_header Cache-Control "public, max-age=604800";
        expires 7d;
    }

    # API requests
    location /api/ {
        limit_req zone=api burst=5 nodelay;
        
        proxy_pass http://chatbot_backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    # Health check
    location /health {
        access_log off;
        proxy_pass http://chatbot_backend;
    }
}
```

---

## 4. Docker Compose with SSL

Use `docker-compose.ssl.yml`:

```bash
# Set environment variables
export CERTBOT_EMAIL=admin@your-domain.com
export CERTBOT_DOMAIN=your-domain.com
export NGINX_HOST=your-domain.com
export NGINX_PORT=443

# Start with SSL
docker-compose -f docker-compose.ssl.yml --profile ssl up -d
```

---

## 5. SSL Testing

### Test SSL Certificate

```bash
# Test with OpenSSL
openssl s_client -connect your-domain.com:443

# Test with curl
curl -I https://your-domain.com

# Check certificate expiration
curl -I https://your-domain.com 2>&1 | grep -i "notBefore\|notAfter"
```

### SSL Labs Test

Visit: https://www.ssllabs.com/ssltest/analyze.html?d=your-domain.com

Expected: **A or A+** rating

---

## 6. Environment Variables for SSL

Create `.env.ssl`:

```env
# SSL Configuration
CERTBOT_EMAIL=admin@your-domain.com
CERTBOT_DOMAIN=your-domain.com
NGINX_HOST=your-domain.com
NGINX_PORT=443

# SSL Options
SSL_CERT_PATH=/etc/letsencrypt/live/your-domain.com/fullchain.pem
SSL_KEY_PATH=/etc/letsencrypt/live/your-domain.com/privkey.pem
SSL_RENEW_FREQUENCY=12h

# Security
HSTS_MAX_AGE=63072000
HSTS_INCLUDE_SUBDOMAINS=true
HSTS_PRELOAD=true
```

---

## 7. Certificate Renewal Workflow

### Manual Renewal

```bash
# Renew certificate
docker-compose -f docker-compose.ssl.yml exec certbot certbot renew

# Renew with force
docker-compose -f docker-compose.ssl.yml exec certbot certbot renew --force-renewal

# Dry run (test without actually renewing)
docker-compose -f docker-compose.ssl.yml exec certbot certbot renew --dry-run
```

### Automatic Renewal

The certbot service automatically renews certificates when they're 30 days from expiration.

Monitor renewal:
```bash
docker-compose -f docker-compose.ssl.yml logs -f certbot
```

---

## 8. Troubleshooting SSL

### Certificate Not Found

```bash
# Check certbot logs
docker logs chatbot-certbot

# Verify certificate files exist
ls -la certbot/conf/live/your-domain.com/
```

### Port 80/443 Already in Use

```bash
# Find process using port
lsof -i :80
lsof -i :443

# Change ports in docker-compose.yml
ports:
  - "8080:80"
  - "8443:443"
```

### Nginx Configuration Error

```bash
# Test nginx configuration
docker-compose exec nginx nginx -t

# View nginx logs
docker-compose logs -f nginx
```

### Domain Not Resolving

```bash
# Verify DNS
nslookup your-domain.com
dig your-domain.com

# Wait for DNS propagation (up to 24 hours)
```

---

## 9. Monitoring SSL

### Check Certificate Status

```bash
# Days until expiration
docker exec chatbot-certbot certbot certificates

# Set up alerts
# (Add to your monitoring system)
```

### Renewal Alerts

Certbot sends emails to the configured address 30 days before expiration.

---

## 10. Production SSL Deployment Checklist

- [ ] Domain properly configured
- [ ] Port 80 and 443 accessible
- [ ] Certbot service running
- [ ] Certificate generation successful
- [ ] Nginx configured with SSL paths
- [ ] HTTP redirects to HTTPS
- [ ] SSL Labs test shows A+ rating
- [ ] HSTS header configured
- [ ] Renewal automation working
- [ ] Monitoring and alerts set up

---

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Certificate not renewing | Check certbot logs: `docker logs chatbot-certbot` |
| Domain not resolving | Wait for DNS propagation, verify with `dig` |
| Port 443 in use | Change port or stop conflicting service |
| Invalid certificate | Delete and regenerate: `certbot delete`, then renew |
| Mixed content warnings | Ensure all external resources use HTTPS |

---

## Security Best Practices

1. **Use TLS 1.2 minimum** (TLS 1.3 preferred)
2. **Enable HSTS** (HTTP Strict-Transport-Security)
3. **Set security headers** (X-Frame-Options, X-Content-Type-Options)
4. **Regular certificate renewal** (automatic with certbot)
5. **Monitor SSL labs score** (aim for A+)
6. **Update Nginx regularly** (security patches)

---

For more information:
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
- [Certbot Documentation](https://certbot.eff.org/docs/)
- [Nginx SSL Configuration](https://nginx.org/en/docs/http/ngx_http_ssl_module.html)
- [Mozilla SSL Configuration Generator](https://ssl-config.mozilla.org/)
