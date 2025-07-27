# Docker Development Environment

**Author:** nunezlagos  
**Description:** Complete development environment with Docker including multiple databases, development servers and administration tools.

**Architecture:** Traefik reverse proxy with SSL support, multiple development services, and organized project structure.

## Quick Start Guide

### System Requirements

**Compatible systems:**
- Ubuntu 20.04 or higher
- Debian 11 or higher
- Arch Linux

**Minimum requirements:**
- 4GB RAM
- 20GB free space
- Internet connection

**Install Git (if not available):**
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install git

# Arch Linux
sudo pacman -S git
```

### Installation

**1. Clone the repository:**
```bash
git clone https://github.com/nunezlagos/docker-dev-env.git
cd docker-dev-env
```

**2. Run automatic installation:**
```bash
chmod +x setup.sh
./setup.sh
```

**3. Restart your session:**
```bash
# After installation, close and reopen your terminal
# Or execute:
newgrp docker
```

### Starting the Environment

**Configure environment (optional):**
```bash
cp .env.example .env
# Edit .env file with your preferred settings
```

**Start all services:**
```bash
# Simple way (recommended)
docker-compose up -d

# Or using specific config
docker-compose -f config/stack-compose.yml up -d

# Or using the provided script
   ./scripts/up.sh
   ```

## Daily Workflow

### Quick Start for Daily Development

1. **Start the environment:**
   ```bash
   # Opción simple
   docker-compose up -d
   
   # O usando el script
   ./scripts/up.sh
   ```

2. **Access services:**
   - **Development servers:** http://php.localhost, http://python.localhost, http://node.localhost
   - **Static files:** http://static.localhost (optional)
   - **Email testing:** http://mail.localhost
   - **Database admin:** http://localhost:8081 (Adminer)
   - **Traefik dashboard:** http://localhost:8080

3. **Create a new project:**
   ```bash
   ./project-manager.sh create php personal my-project
   ./project-manager.sh create python work api-backend
   ./project-manager.sh create angular personal dashboard
   ```

4. **Access containers for development:**
   ```bash
   docker exec -it stack_php_1 bash
   docker exec -it stack_python_1 bash
   docker exec -it stack_nodejs_1 sh
   ```

5. **Stop the environment when done:**
   ```bash
   docker-compose -f config/stack-compose.yml down
   docker-compose -f config/traefik-compose.yml down
   ```

**Or manually:**
```bash
docker-compose -f config/traefik-compose.yml up -d
docker-compose -f config/stack-compose.yml up -d
```

### Verification

**Check running containers:**
```bash
docker ps
```

**View logs if issues occur:**
```bash
docker-compose logs
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

## ¿Dónde Está Todo? - Acceso a los Servicios

Una vez que hayas ejecutado `./up.sh`, podrás acceder a todos los servicios desde tu navegador:

## Available Services

### Databases

| Service | Port | User | Password | Database |
|---------|------|------|----------|----------|
| MySQL | 3306 | devuser | devpass | appdb |
| PostgreSQL | 5432 | devuser | devpass | appdb |
| MongoDB | 27017 | - | - | - |
| Redis | 6379 | - | - | - |
| MailHog | 8025 | - | - | - |

### Development Servers

| Service | Access URL | Debug Port | Description |
|---------|------------|------------|-------------|
| PHP 8.2 | http://localhost:8085 | 9003 | Apache + PHP with Xdebug |
| Python 3.11 | http://localhost:8000 | 5678 | Flask, Django, FastAPI |
| Node.js 18 | http://localhost:3000 | 9229 | Angular, Vue, React |
| Nginx | http://localhost:8086 | - | Static file server |

### Administration Tools

| Tool | URL | User | Password |
|------|-----|------|----------|
| Traefik Dashboard | http://localhost:8080 | - | - |
| phpMyAdmin (MySQL) | http://localhost:8081 | devuser | devpass |
| pgAdmin (PostgreSQL) | http://localhost:8082 | admin@admin.com | admin |
| Mongo Express (MongoDB) | http://localhost:8083 | - | - |
| Redis Commander | http://localhost:8084 | - | - |
| Adminer (Universal DB) | http://localhost:8087 | see below | see below |

### Development Servers

| Service | URL | Debug Port | Description |
|---------|-----|------------|-------------|
| **PHP + Apache** | http://localhost:8085 | 9003 | PHP server with Apache and Xdebug |
| **Python** | http://localhost:8000 | 5678 | Python environment with Flask, Django, FastAPI |
| **Node.js** | http://localhost:3000 | 9229 | Node.js environment with Angular, Vue, React |
| **Nginx** | http://localhost:8086 | - | Static web server |

### 🔗 Conexiones Directas a Bases de Datos

**MySQL:**
```bash
# Conectar desde terminal
mysql -h localhost -P 3306 -u devuser -p
# Contraseña: devpass
```

**PostgreSQL:**
```bash
# Conectar desde terminal
psql -h localhost -p 5432 -U devuser -d appdb
# Contraseña: devpass
```

**MongoDB:**
```bash
# Conectar desde terminal
mongo mongodb://localhost:27017
# O con mongosh:
mongosh mongodb://localhost:27017
```

**Redis:**
```bash
# Conectar desde terminal
redis-cli -h localhost -p 6379
```

### 📋 Datos de Conexión para Bases de Datos

**Para MySQL (phpMyAdmin):**
- Servidor: `mysql`
- Usuario: `devuser`
- Contraseña: `devpass`
- Base de datos: `appdb`

**Para PostgreSQL (pgAdmin):**
- Servidor: `postgres`
- Usuario: `devuser`
- Contraseña: `devpass`
- Base de datos: `appdb`

**Para Adminer (Universal):**
- **MySQL:** Servidor: `mysql`, Usuario: `devuser`, Contraseña: `devpass`, BD: `appdb`
- **PostgreSQL:** Servidor: `postgres`, Usuario: `devuser`, Contraseña: `devpass`, BD: `appdb`
- **MongoDB:** No compatible con Adminer (usar Mongo Express)
- **Redis:** No compatible con Adminer (usar Redis Commander)

### 💻 Cómo Usar los Servidores de Desarrollo

### 📁 Organización de Proyectos
Cada tecnología tiene 3 carpetas disponibles:
- **General**: Para proyectos de prueba y aprendizaje
- **Personal**: Para proyectos personales
- **Trabajo**: Para proyectos profesionales

### PHP + Apache (Puerto 8085, Debug 9003)
**Carpetas disponibles:**
- `~/dev/docker/php-projects/` - Proyectos generales
- `~/dev/docker/php-personal/` - Proyectos personales  
- `~/dev/docker/php-work/` - Proyectos de trabajo

**Uso:**
1. Coloca tus archivos PHP en cualquiera de las carpetas
2. Accede a: http://localhost:8085, http://localhost:8085/personal, http://localhost:8085/work
3. **Debugging**: Configura tu IDE para conectar al puerto 9003
4. Para reiniciar: `docker-compose restart php`

### Python (Puerto 8000, Debug 5678)
**Carpetas disponibles:**
- `~/dev/docker/python-projects/` - Proyectos generales
- `~/dev/docker/python-personal/` - Proyectos personales
- `~/dev/docker/python-work/` - Proyectos de trabajo

**Frameworks incluidos:** Flask, Django, FastAPI, Jupyter
**Uso:**
1. Accede al contenedor: `docker exec -it stack_python_1 bash`
2. Navega a tu carpeta: `cd personal` o `cd work`
3. Crea tu proyecto:
   - **Flask**: `flask run --host=0.0.0.0 --port=8000`
   - **Django**: `django-admin startproject mi_proyecto && cd mi_proyecto && python manage.py runserver 0.0.0.0:8000`
   - **FastAPI**: `uvicorn main:app --host 0.0.0.0 --port 8000 --reload`
4. **Debugging**: Configura tu IDE para conectar al puerto 5678

### Node.js (Puerto 3000, Debug 9229)
**Carpetas disponibles:**
- `~/dev/docker/node-projects/` - Proyectos generales
- `~/dev/docker/node-personal/` - Proyectos personales
- `~/dev/docker/node-work/` - Proyectos de trabajo

**Frameworks incluidos:** Angular CLI, Vue CLI, Create React App, TypeScript
**Uso:**
1. Accede al contenedor: `docker exec -it stack_nodejs_1 sh`
2. Navega a tu carpeta: `cd personal` o `cd work`
3. Crea tu proyecto:
   - **Angular**: `ng new mi-app && cd mi-app && ng serve --host 0.0.0.0`
   - **React**: `npx create-react-app mi-app && cd mi-app && npm start`
   - **Vue**: `vue create mi-app && cd mi-app && npm run serve`
   - **Node.js simple**: `npm init && node app.js`
4. **Debugging**: Configura tu IDE para conectar al puerto 9229
5. Para desarrollo: `npm install -g nodemon && nodemon --inspect=0.0.0.0:9229 app.js`

### Nginx (Puerto 8086)
**Carpeta:**
- `~/dev/docker/nginx-html/` - Archivos estáticos

**Uso:**
1. Coloca tus archivos HTML/CSS/JS en la carpeta
2. Accede a: http://localhost:8086

## Integrated Project Manager

This environment includes a project management script that facilitates creation and organization of projects across different technologies.

### Features:
- Automatic project creation with base structure
- Organization by categories: General, Personal, Work
- Support for multiple technologies: PHP, Python, Node.js, Angular, React, Vue
- Project listing and management
- Automatic debugging configuration

### Manager Usage:
```bash
# View complete help
./project-manager.sh help

# Create different project types
./project-manager.sh create php personal my-blog
./project-manager.sh create python work api-rest
./project-manager.sh create angular personal dashboard
./project-manager.sh create node work backend-api

# List projects by technology
./project-manager.sh list php
./project-manager.sh list python

# View environment status
./project-manager.sh info
```

### Generated Folder Structure:
```
~/dev/docker/
├── php-personal/my-blog/
├── php-work/client-project/
├── python-personal/api-rest/
├── node-work/backend-api/
└── ...
```

## Basic Usage Commands

### Environment Management

```bash
# Start all services
./up.sh

# Start manually
docker-compose -f config/traefik-compose.yml up -d
docker-compose -f config/stack-compose.yml up -d

# Stop all services
docker-compose -f config/stack-compose.yml down
docker-compose -f config/traefik-compose.yml down

# View service status
docker-compose -f config/stack-compose.yml ps

# View logs
docker-compose -f config/stack-compose.yml logs -f

# Restart services
docker-compose -f config/stack-compose.yml restart

# Start only static server (Nginx)
docker-compose -f config/stack-compose.yml --profile static up nginx
```

### 📁 Gestión de Proyectos (Nuevo)
```bash
# Usar el gestor de proyectos
./project-manager.sh help

# Crear proyectos
./project-manager.sh create php personal mi-blog
./project-manager.sh create python work api-rest
./project-manager.sh create angular personal dashboard
./project-manager.sh create react work ecommerce

# Listar proyectos
./project-manager.sh list php
./project-manager.sh list python
./project-manager.sh list node

# Ver información del entorno
./project-manager.sh info
```

### 🔄 Reiniciar un Servicio Específico
```bash
# Reiniciar MySQL
docker-compose -f stack-compose.yml restart mysql

# Reiniciar PostgreSQL
docker-compose -f stack-compose.yml restart postgres

# Reiniciar MongoDB
docker-compose -f stack-compose.yml restart mongodb
```

### 📊 Ver el Estado de los Servicios
```bash
# Ver qué contenedores están corriendo
docker ps

# Ver todos los contenedores (incluso los detenidos)
docker ps -a
```

### Container Access
```bash
# Access containers
docker exec -it stack_nodejs_1 sh
docker exec -it stack_python_1 bash
docker exec -it stack_php_1 bash
docker exec -it stack_mysql_1 mysql -u devuser -p
```

### 📝 Ver Logs (Para Solucionar Problemas)
```bash
# Ver logs de todos los servicios
docker-compose -f stack-compose.yml logs

# Ver logs de un servicio específico
docker-compose -f stack-compose.yml logs mysql

# Ver logs en tiempo real
docker-compose -f stack-compose.yml logs -f
```

## ❗ Solución de Problemas Comunes

### El entorno no inicia
```bash
# Verificar que Docker está corriendo
sudo systemctl status docker

# Si no está corriendo, iniciarlo
sudo systemctl start docker

# Verificar que estás en el grupo docker
groups $USER | grep docker

# Si no estás en el grupo, agregarte y reiniciar sesión
sudo usermod -aG docker $USER
newgrp docker
```

### Un servicio no funciona
```bash
# Ver qué contenedores están corriendo
docker ps

# Ver logs del servicio problemático
docker-compose -f stack-compose.yml logs nombre_del_servicio

# Reiniciar el servicio
docker-compose -f stack-compose.yml restart nombre_del_servicio
```

### Error "puerto ya en uso"
```bash
# Ver qué está usando el puerto (ejemplo puerto 3306)
sudo netstat -tulpn | grep 3306

# Detener el servicio que usa el puerto
sudo systemctl stop mysql  # ejemplo para MySQL

# O cambiar el puerto en el archivo docker-compose
```

### Limpiar todo y empezar de nuevo
```bash
# Detener y eliminar todo
docker-compose -f stack-compose.yml down -v
docker-compose -f traefik-compose.yml down -v

# Limpiar imágenes y contenedores
docker system prune -a

# Volver a iniciar
./up.sh
```

## Additional Information

### Architecture Overview

**Traefik Reverse Proxy:** All development services are accessible through Traefik with automatic routing and SSL support.

### Port Configuration

#### Web Services
- **Traefik Dashboard:** Port 8080
- **PHP Development:** http://php.localhost (via Traefik)
- **Python Development:** http://python.localhost (via Traefik)
- **Node.js Development:** http://node.localhost (via Traefik)
- **Static Files (Nginx):** http://static.localhost (via Traefik, optional)

#### Databases
- **MySQL:** Port 3306
- **PostgreSQL:** Port 5432
- **MongoDB:** Port 27017
- **Redis:** Port 6379

#### Debugging Ports
- **PHP (Xdebug):** Port 9003
- **Python (debugpy):** Port 5678
- **Node.js (Inspector):** Port 9229

#### Administration Tools
- **Adminer:** Port 8081
- **phpMyAdmin:** Port 8082
- **Mongo Express:** Port 8083
- **Redis Commander:** Port 8084

### Development Tips

#### Development Tips

#### Python Debugging
- Install `debugpy` in your project: `pip install debugpy`
- Configure your IDE to connect to port 5678
- Use: `python -m debugpy --listen 0.0.0.0:5678 --wait-for-client your_script.py`

#### Static Files
- Use Nginx service only when needed: `docker-compose --profile static up nginx`
- Access via http://static.localhost when Nginx is running

#### Email Testing
- Use MailHog at http://localhost:8025 to test email functionality
- SMTP Configuration: Use `localhost:1025` as SMTP server in your applications

#### Daily Workflow
- See `docs/WORKFLOW.md` for complete daily usage guide

### Important Notes

**Port Usage:**
- 8080-8087: Administration tools
- 3000, 8000, 8085, 8086: Development servers
- 3306, 5432, 27017, 6379: Database connections
- 9003, 5678, 9229: Debugging ports

**Project Organization:**
- PHP: `~/dev/docker/php-projects/`, `~/dev/docker/php-personal/`, `~/dev/docker/php-work/`
- Python: `~/dev/docker/python-projects/`, `~/dev/docker/python-personal/`, `~/dev/docker/python-work/`
- Node.js: `~/dev/docker/node-projects/`, `~/dev/docker/node-personal/`, `~/dev/docker/node-work/`
- Nginx: `~/dev/docker/nginx-html/`

**Debugging Configuration:**
- PHP: Xdebug on port 9003
- Python: debugpy on port 5678
- Node.js: Inspector on port 9229

**Pre-installed Frameworks:**
- PHP: Xdebug enabled
- Python: Flask, Django, FastAPI, Jupyter
- Node.js: Angular CLI, Vue CLI, React, TypeScript

**Development Best Practices:**
1. Always use `./up.sh` to start the environment
2. Data is automatically persisted across restarts
3. Check logs if issues occur: `docker-compose logs`
4. For local development only - not for production use
5. Restart Apache if changing PHP configuration
6. Use `--reload` flag for Python frameworks auto-reload
7. Use `nodemon` for Node.js development auto-reload

### Troubleshooting

**Common Issues:**

1. **"Port already in use"**
   ```bash
   # Check what's using the port
   sudo lsof -i :8080
   # Kill the process
   sudo kill -9 [PID]
   ```

2. **"Cannot connect to Docker"**
   ```bash
   # Restart Docker
   sudo systemctl restart docker
   # Add user to docker group
   sudo usermod -aG docker $USER
   ```

3. **"Container won't start"**
   ```bash
   # View detailed logs
   docker-compose logs [service-name]
   ```

**Useful Commands:**
```bash
# Clean all Docker (CAUTION!)
docker system prune -a

# View space usage
docker system df

# Update images
docker-compose pull
```

---

## Documentation Structure

```
├── docs/                 # Documentation
│   ├── ARCHITECTURE.md   # Technical documentation
│   └── WORKFLOW.md       # Daily workflow guide
└── README.md             # Main documentation
```

---

**Author:** nunezlagos  
**Created for developers who want simplicity and power.**
