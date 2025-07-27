# Docker Development Environment Architecture

**Author:** nunezlagos  
**Version:** 2.0  
**Description:** Professional development environment with Traefik reverse proxy

## Architecture Overview

### Core Components

1. **Traefik Reverse Proxy**
   - Main entry point for all services
   - Automatic SSL certificate management
   - Dynamic service discovery
   - Dashboard: http://localhost:8080

2. **Development Services**
   - PHP 8.2 + Apache: http://php.localhost
   - Python 3.11: http://python.localhost
   - Node.js 18: http://node.localhost
   - Nginx (optional): http://static.localhost
   - MailHog: http://mailhog.localhost

3. **Database Services**
   - MySQL 8.0 (Port 3306)
   - PostgreSQL 15 (Port 5432)
   - MongoDB 6.0 (Port 27017)
   - Redis 7.0 (Port 6379)

4. **Administration Tools**
   - Adminer (Port 8081)
   - phpMyAdmin (Port 8082)
   - Mongo Express (Port 8083)
   - Redis Commander (Port 8084)

### Network Architecture

```
Internet/Localhost
        |
    Traefik (8080)
        |
    ┌───────┼───────┐
    │       │       │
   PHP    Python  Node.js
 (Apache) (Flask) (Express)
    │       │       │
    └───────┼───────┘
            │
    Database Layer
   (MySQL, PostgreSQL,
    MongoDB, Redis)
```

### Service Routing

| Service | URL | Container Port | Debug Port |
|---------|-----|----------------|------------|
| PHP | http://php.localhost | 80 | 9003 |
| Python | http://python.localhost | 8000 | 5678 |
| Node.js | http://node.localhost | 3000 | 9229 |
| Nginx | http://static.localhost | 80 | - |
| MailHog | http://mailhog.localhost | 8025 | - |

### Project Organization

```
docker-dev-env/
├── config/               # Docker configuration files
│   ├── stack-compose.yml  # Main services configuration
│   ├── traefik-compose.yml # Traefik reverse proxy
│   └── *.conf, *.ini      # Service configurations
├── projects/              # Development projects
│   ├── php/              # PHP projects
│   ├── python/           # Python projects
│   ├── nodejs/           # Node.js projects
│   └── static/           # Static files for Nginx
├── scripts/              # Management scripts
│   ├── up.sh            # Start environment
│   ├── setup.sh         # Initial setup
│   └── project-manager.sh # Project management
├── docs/                 # Documentation
│   └── ARCHITECTURE.md   # Technical documentation
└── README.md             # Main documentation
```

### Key Features

- **Automatic SSL:** Traefik handles SSL certificates
- **Service Discovery:** Dynamic routing based on labels
- **Development Debugging:** Dedicated ports for each technology
- **Project Management:** Organized folder structure
- **Optional Services:** Nginx only starts when needed
- **Persistent Data:** All data survives container restarts

### Security Considerations

- All services run in isolated Docker network
- Database access restricted to development environment
- Debug ports only accessible locally
- No production credentials in configuration

### Performance Optimizations

- Traefik caching for static content
- Persistent volumes for faster container startup
- Optimized Docker images
- Minimal resource allocation

---

**Note:** This environment is designed for local development only. Do not use in production without proper security hardening.