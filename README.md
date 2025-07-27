# Docker Development Environment

Comprehensive Docker-based development environment featuring Traefik reverse proxy, multiple database systems, and essential development tools with automated setup and validation.

## System Requirements

### Supported Operating Systems
- Ubuntu 20.04 LTS or later
- Debian 11 (Bullseye) or later  
- Arch Linux (current)

### Hardware Requirements
- Minimum: 4GB RAM, 20GB free disk space
- Recommended: 8GB RAM, 50GB free disk space
- Network: Internet connection required for package downloads

### Pre-Installation Validation

Execute the following commands to verify system compatibility:

```bash
# Verify operating system and version
lsb_release -a

# Check system resources
free -h
df -h /

# Validate required utilities
curl --version || echo "curl not found - install with: sudo apt install curl"
git --version || echo "git not found - install with: sudo apt install git"

# Check current Docker installation (if any)
docker --version 2>/dev/null || echo "Docker not installed - will be installed by setup script"
docker-compose --version 2>/dev/null || echo "Docker Compose not installed - will be installed by setup script"
```

## Installation

### Automated Setup Process

```bash
# Clone repository
git clone https://github.com/nunezlagos/docker-dev-env.git
cd docker-dev-env

# Grant execution permissions
chmod +x setup.sh

# Execute automated installation
./setup.sh
```

### Installation Process Overview

The setup script performs the following operations:
1. System validation and dependency resolution
2. Docker Engine installation and configuration
3. Docker Compose installation with version compatibility checks
4. User group management and permissions
5. Firewall configuration (UFW on Ubuntu/Debian)
6. Docker network creation
7. Environment file generation
8. Service composition file deployment
9. Startup script creation
10. Comprehensive system validation

### Post-Installation Verification

Execute these commands to validate the installation:

```bash
# Verify Docker daemon status
sudo systemctl status docker --no-pager

# Confirm user group membership
id $USER | grep docker

# Test Docker functionality
docker run --rm hello-world

# Validate Docker Compose installation
docker-compose --version
docker compose version 2>/dev/null || echo "Docker Compose v2 not available"

# Check network configuration
docker network ls | grep traefik

# Verify firewall status (Ubuntu/Debian)
sudo ufw status 2>/dev/null || echo "UFW not configured"
```

## 🎯 Comandos Post-Instalación

### Verificar que Docker esté funcionando:
```bash
docker --version
docker-compose --version
sudo systemctl status docker
```

### Verificar que estés en el grupo docker:
```bash
groups $USER
```

### Si necesitas activar el grupo docker sin reiniciar:
```bash
newgrp docker
```

### Verificar la red de Traefik:
```bash
docker network ls | grep traefik
```

## Usage

### Service Management

```bash
# Navigate to development environment
cd ~/dev/docker

# Start complete stack
./up.sh

# Alternative: Manual service startup
cd traefik && docker-compose up -d
cd ../stack && docker-compose up -d

# Stop all services
cd ~/dev/docker/stack && docker-compose down
cd ../traefik && docker-compose down

# Stop services with volume removal (data destruction)
cd ~/dev/docker/stack && docker-compose down -v
cd ../traefik && docker-compose down -v
```

### Log Management

```bash
# View aggregated logs
cd ~/dev/docker/stack && docker-compose logs

# Real-time log monitoring
docker-compose logs -f

# Service-specific log analysis
docker-compose logs mysql
docker-compose logs postgresql
docker-compose logs mongodb
docker-compose logs redis
docker-compose logs traefik

# Log filtering by time
docker-compose logs --since="1h" mysql
docker-compose logs --tail=100 traefik
```

### Container Management

```bash
# View running containers
docker ps

# View all containers (including stopped)
docker ps -a

# Execute commands in running containers
docker exec -it mysql_container mysql -u root -p
docker exec -it postgres_container psql -U postgres
```

## Service Access

### Administrative Interfaces

| Service | URL | Authentication |
|---------|-----|---------------|
| Traefik Dashboard | http://localhost:8080 | None required |
| phpMyAdmin (MySQL) | http://localhost:8081 | root / rootpassword |
| pgAdmin (PostgreSQL) | http://localhost:8082 | admin@admin.com / admin |
| Mongo Express (MongoDB) | http://localhost:8083 | admin / pass |
| Redis Commander | http://localhost:8084 | None required |

### Direct Database Connections

```bash
# MySQL Database Connection
mysql -h localhost -P 3306 -u devuser -p
# Password: devpassword
# Root access: mysql -h localhost -P 3306 -u root -p (Password: rootpassword)

# PostgreSQL Database Connection
psql -h localhost -p 5432 -U postgres -d postgres
# Password: postgres

# MongoDB Database Connection
mongo mongodb://admin:mongopassword@localhost:27017/admin
# Alternative: mongosh mongodb://admin:mongopassword@localhost:27017/admin

# Redis Database Connection
redis-cli -h localhost -p 6379
# Authentication: AUTH redispassword
```

### Connection Parameters

```bash
# MySQL
Host: localhost
Port: 3306
Database: devdb
Username: devuser
Password: devpassword

# PostgreSQL
Host: localhost
Port: 5432
Database: postgres
Username: postgres
Password: postgres

# MongoDB
Host: localhost
Port: 27017
Database: admin
Username: admin
Password: mongopassword

# Redis
Host: localhost
Port: 6379
Password: redispassword
```

## Maintenance

### Docker System Maintenance

```bash
# System cleanup (removes unused resources)
docker system prune -f

# Comprehensive cleanup including volumes (data destruction)
docker system prune -a --volumes -f

# Selective cleanup operations
docker container prune -f    # Remove stopped containers
docker image prune -f         # Remove unused images
docker network prune -f       # Remove unused networks
docker volume prune -f        # Remove unused volumes (data loss)

# View system resource usage
docker system df
```

### Service Management

```bash
# Restart Docker daemon
sudo systemctl restart docker

# Verify Docker daemon status
sudo systemctl status docker --no-pager

# Enable Docker daemon auto-start
sudo systemctl enable docker

# View Docker daemon logs
journalctl -u docker.service --no-pager
```

### Container Updates

```bash
# Update container images
cd ~/dev/docker/stack
docker-compose pull

# Recreate containers with updated images
docker-compose up -d --force-recreate

# Update specific service
docker-compose pull mysql
docker-compose up -d --no-deps mysql
```

### Backup Operations

```bash
# Database backup examples
docker exec mysql_container mysqldump -u root -prootpassword devdb > backup_mysql.sql
docker exec postgres_container pg_dump -U postgres postgres > backup_postgres.sql
docker exec mongo_container mongodump --host localhost --port 27017 --out /backup

# Volume backup
docker run --rm -v mysql_data:/data -v $(pwd):/backup alpine tar czf /backup/mysql_backup.tar.gz /data
```

## Troubleshooting

### Docker Compose Compatibility

```bash
# Verify Docker Compose installation
docker-compose --version
docker compose version 2>/dev/null || echo "Docker Compose v2 not available"

# Legacy Docker Compose syntax (v1)
docker-compose up -d
docker-compose down

# Modern Docker Compose syntax (v2)
docker compose up -d
docker compose down

# Force Docker Compose v1 usage
alias docker-compose="docker-compose"
```

### Permission Resolution

```bash
# Verify current user permissions
id $USER
groups $USER

# Add user to docker group
sudo usermod -aG docker $USER

# Apply group changes without logout
newgrp docker

# Verify Docker access
docker run --rm hello-world

# Fix Docker socket permissions (if needed)
sudo chmod 666 /var/run/docker.sock
```

### Network Configuration

```bash
# Verify Docker networks
docker network ls
docker network inspect traefik

# Recreate Docker network
docker network rm traefik
docker network create traefik

# Check port conflicts
sudo netstat -tulpn | grep :8080
sudo lsof -i :8080
```

### Firewall Configuration

```bash
# UFW status verification
sudo ufw status verbose

# Configure required ports
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 8080:8084/tcp

# Reset UFW configuration
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80,443,8080:8084/tcp
sudo ufw --force enable
```

### Service Diagnostics

```bash
# Container status verification
docker ps -a
docker stats

# Service-specific troubleshooting
docker-compose logs --tail=50 mysql
docker-compose logs --tail=50 traefik

# Container health checks
docker inspect mysql_container | grep Health
docker exec mysql_container mysqladmin ping

# Resource monitoring
docker system df
docker system events --since 1h
```

### Common Error Resolution

```bash
# "Port already in use" error
sudo lsof -i :8080
sudo kill -9 <PID>

# "Network not found" error
docker network create traefik

# "Permission denied" error
sudo chown -R $USER:$USER ~/dev/docker
chmod +x ~/dev/docker/up.sh

# "Container name conflict" error
docker rm -f conflicting_container_name
```

## Project Structure

```
docker-dev-env/
├── setup.sh                    # Automated installation script
├── README.md                   # Comprehensive documentation
├── docker-files/
│   ├── traefik-compose.yml     # Traefik reverse proxy configuration
│   └── stack-compose.yml       # Database and service stack
└── ~/dev/docker/               # Runtime environment (created during setup)
    ├── .env                    # Environment configuration
    ├── up.sh                   # Service orchestration script
    ├── traefik/
    │   └── docker-compose.yml  # Traefik service definition
    └── stack/
        └── docker-compose.yml  # Application stack definition
```

## Configuration Management

### Environment Variables

Modify `~/dev/docker/.env` for system customization:

```bash
# Project identification
COMPOSE_PROJECT_NAME=devenv
TRAEFIK_DOMAIN=localhost
TRAEFIK_API_DASHBOARD=true
TRAEFIK_LOG_LEVEL=INFO

# Database authentication
MYSQL_ROOT_PASSWORD=rootpassword
MYSQL_DATABASE=devdb
MYSQL_USER=devuser
MYSQL_PASSWORD=devpassword

# Redis configuration
REDIS_PASSWORD=redispassword

# Network topology
DOCKER_NETWORK=traefik-network
```

### Service Extension

Extend functionality by modifying `~/dev/docker/stack/docker-compose.yml`:

```yaml
services:
  custom-service:
    image: custom-image:latest
    container_name: custom_service
    restart: unless-stopped
    networks:
      - traefik
    environment:
      - CUSTOM_VAR=value
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.custom.rule=Host(`custom.localhost`)"
      - "traefik.http.services.custom.loadbalancer.server.port=8080"
    volumes:
      - custom_data:/app/data

volumes:
  custom_data:
    driver: local

networks:
  traefik:
    external: true
```

## Technical Specifications

### System Compatibility
- Ubuntu 20.04 LTS or later
- Debian 11 (Bullseye) or later
- Arch Linux (current release)
- Docker Engine 20.10 or later
- Docker Compose 1.29 or later

### Network Architecture
- All services communicate through the `traefik` Docker network
- Traefik acts as reverse proxy and load balancer
- Database persistence via Docker volumes
- Firewall configuration for secure external access

### Security Considerations

```bash
# Change default passwords in .env file
# Restrict network access using UFW
# Use Docker secrets for sensitive data
# Implement SSL/TLS certificates for production
# Regular security updates for base images
```

### Performance Optimization

```bash
# Monitor resource usage
docker stats
docker system df

# Optimize container resources
# Set memory and CPU limits in docker-compose.yml
# Use multi-stage builds for custom images
# Implement health checks for services
```

## Author

**nunezlagos** - Professional Docker Development Environment
