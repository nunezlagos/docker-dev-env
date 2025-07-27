# Entorno de Desarrollo Docker

**Autor:** nunezlagos  
**Descripción:** Entorno de desarrollo completo con Docker incluyendo múltiples bases de datos, servidores de desarrollo y herramientas de administración.

**Arquitectura:** Proxy reverso Traefik con soporte SSL, múltiples servicios de desarrollo y estructura de proyecto organizada.

## Guía de Inicio Rápido

### Requisitos del Sistema

**Sistemas compatibles:**
- Ubuntu 20.04 o superior
- Debian 11 o superior
- Arch Linux

**Requisitos mínimos:**
- 4GB RAM
- 20GB espacio libre
- Conexión a internet

**Instalar Git (si no está disponible):**
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install git

# Arch Linux
sudo pacman -S git
```

### Instalación

**1. Clonar el repositorio:**
```bash
git clone https://github.com/nunezlagos/docker-dev-env.git
cd docker-dev-env
```

**2. Ejecutar instalación automática:**
```bash
chmod +x setup.sh
./setup.sh
```

**3. Reiniciar tu sesión:**
```bash
# Después de la instalación, cierra y reabre tu terminal
# O ejecuta:
newgrp docker
```

### Iniciando el Entorno

**Configurar entorno (opcional):**
```bash
cp .env.example .env
# Editar archivo .env con tus configuraciones preferidas
```

**Iniciar todos los servicios:**
```bash
# Forma simple (recomendada)
docker-compose up -d

# O usando configuración específica
docker-compose -f config/stack-compose.yml up -d

# O usando el script proporcionado
   ./scripts/up.sh
   ```

## Flujo de Trabajo Diario

### Inicio Rápido para Desarrollo Diario

1. **Iniciar el entorno:**
   ```bash
   # Opción simple
   docker-compose up -d
   
   # O usando el script
   ./scripts/up.sh
   ```

2. **Acceder a los servicios:**
   - **Servidores de desarrollo:** http://php.localhost, http://python.localhost, http://node.localhost
   - **Archivos estáticos:** http://static.localhost (opcional)
   - **Pruebas de email:** http://mail.localhost
   - **Administrador de BD:** http://localhost:8081 (Adminer)
   - **Panel de Traefik:** http://localhost:8080

3. **Crear un nuevo proyecto:**
   ```bash
   ./project-manager.sh create php personal mi-proyecto
   ./project-manager.sh create python work api-backend
   ./project-manager.sh create angular personal dashboard
   ```

4. **Acceder a contenedores para desarrollo:**
   ```bash
   docker exec -it stack_php_1 bash
   docker exec -it stack_python_1 bash
   docker exec -it stack_nodejs_1 sh
   ```

5. **Detener el entorno al terminar:**
   ```bash
   docker-compose -f config/stack-compose.yml down
   docker-compose -f config/traefik-compose.yml down
   ```

**O manualmente:**
```bash
docker-compose -f config/traefik-compose.yml up -d
docker-compose -f config/stack-compose.yml up -d
```

### Verificación

**Verificar contenedores en ejecución:**
```bash
docker ps
```

**Ver logs si ocurren problemas:**
```bash
docker-compose logs
```

## Comandos Post-Instalación

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

## Servicios Disponibles

### Bases de Datos

| Servicio | Puerto | Usuario | Contraseña | Base de Datos |
|----------|--------|---------|------------|---------------|
| MySQL | 3306 | devuser | devpass | appdb |
| PostgreSQL | 5432 | devuser | devpass | appdb |
| MongoDB | 27017 | - | - | - |
| Redis | 6379 | - | - | - |
| MailHog | 8025 | - | - | - |

### Servidores de Desarrollo

| Servicio | URL de Acceso | Puerto Debug | Descripción |
|----------|---------------|--------------|-------------|
| PHP 8.2 | http://localhost:8085 | 9003 | Apache + PHP con Xdebug |
| Python 3.11 | http://localhost:8000 | 5678 | Flask, Django, FastAPI |
| Node.js 18 | http://localhost:3000 | 9229 | Angular, Vue, React |
| Nginx | http://localhost:8086 | - | Servidor de archivos estáticos |

### Herramientas de Administración

| Herramienta | URL | Usuario | Contraseña |
|-------------|-----|---------|------------|
| Panel Traefik | http://localhost:8080 | - | - |
| phpMyAdmin (MySQL) | http://localhost:8081 | devuser | devpass |
| pgAdmin (PostgreSQL) | http://localhost:8082 | admin@admin.com | admin |
| Mongo Express (MongoDB) | http://localhost:8083 | - | - |
| Redis Commander | http://localhost:8084 | - | - |
| Adminer (BD Universal) | http://localhost:8087 | ver abajo | ver abajo |

### Servidores de Desarrollo

| Servicio | URL | Puerto Debug | Descripción |
|----------|-----|--------------|-------------|
| **PHP + Apache** | http://localhost:8085 | 9003 | Servidor PHP con Apache y Xdebug |
| **Python** | http://localhost:8000 | 5678 | Entorno Python con Flask, Django, FastAPI |
| **Node.js** | http://localhost:3000 | 9229 | Entorno Node.js con Angular, Vue, React |
| **Nginx** | http://localhost:8086 | - | Servidor web estático |

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

## Gestor de Proyectos Integrado

Este entorno incluye un script de gestión de proyectos que facilita la creación y organización de proyectos en diferentes tecnologías.

### Características:
- Creación automática de proyectos con estructura base
- Organización por categorías: General, Personal, Trabajo
- Soporte para múltiples tecnologías: PHP, Python, Node.js, Angular, React, Vue
- Listado y gestión de proyectos
- Configuración automática de debugging

### Uso del Gestor:
```bash
# Ver ayuda completa
./project-manager.sh help

# Crear diferentes tipos de proyectos
./project-manager.sh create php personal mi-blog
./project-manager.sh create python work api-rest
./project-manager.sh create angular personal dashboard
./project-manager.sh create node work backend-api

# Listar proyectos por tecnología
./project-manager.sh list php
./project-manager.sh list python

# Ver estado del entorno
./project-manager.sh info
```

### Estructura de Carpetas Generada:
```
~/dev/docker/
├── php-personal/mi-blog/
├── php-work/proyecto-cliente/
├── python-personal/api-rest/
├── node-work/backend-api/
└── ...
```

## Comandos de Uso Básico

### Gestión del Entorno

```bash
# Iniciar todos los servicios
./up.sh

# Iniciar manualmente
docker-compose -f config/traefik-compose.yml up -d
docker-compose -f config/stack-compose.yml up -d

# Detener todos los servicios
docker-compose -f config/stack-compose.yml down
docker-compose -f config/traefik-compose.yml down

# Ver estado de servicios
docker-compose -f config/stack-compose.yml ps

# Ver logs
docker-compose -f config/stack-compose.yml logs -f

# Reiniciar servicios
docker-compose -f config/stack-compose.yml restart

# Iniciar solo servidor estático (Nginx)
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

### Acceso a Contenedores
```bash
# Acceder a contenedores
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

## Información Adicional

### Resumen de Arquitectura

**Proxy Reverso Traefik:** Todos los servicios de desarrollo son accesibles a través de Traefik con enrutamiento automático y soporte SSL.

### Configuración de Puertos

#### Servicios Web
- **Panel Traefik:** Puerto 8080
- **Desarrollo PHP:** http://php.localhost (vía Traefik)
- **Desarrollo Python:** http://python.localhost (vía Traefik)
- **Desarrollo Node.js:** http://node.localhost (vía Traefik)
- **Archivos Estáticos (Nginx):** http://static.localhost (vía Traefik, opcional)

#### Bases de Datos
- **MySQL:** Puerto 3306
- **PostgreSQL:** Puerto 5432
- **MongoDB:** Puerto 27017
- **Redis:** Puerto 6379

#### Puertos de Debugging
- **PHP (Xdebug):** Puerto 9003
- **Python (debugpy):** Puerto 5678
- **Node.js (Inspector):** Puerto 9229

#### Herramientas de Administración
- **Adminer:** Puerto 8081
- **phpMyAdmin:** Puerto 8082
- **Mongo Express:** Puerto 8083
- **Redis Commander:** Puerto 8084

### Development Tips

#### Consejos de Desarrollo

#### Debugging de Python
- Instala `debugpy` en tu proyecto: `pip install debugpy`
- Configura tu IDE para conectar al puerto 5678
- Usa: `python -m debugpy --listen 0.0.0.0:5678 --wait-for-client tu_script.py`

#### Archivos Estáticos
- Usa el servicio Nginx solo cuando sea necesario: `docker-compose --profile static up nginx`
- Accede vía http://static.localhost cuando Nginx esté corriendo

#### Pruebas de Email
- Usa MailHog en http://localhost:8025 para probar funcionalidad de email
- Configuración SMTP: Usa `localhost:1025` como servidor SMTP en tus aplicaciones

#### Flujo de Trabajo Diario
- Consulta `docs/WORKFLOW.md` para una guía completa de uso diario

### Notas Importantes

**Uso de Puertos:**
- 8080-8087: Herramientas de administración
- 3000, 8000, 8085, 8086: Servidores de desarrollo
- 3306, 5432, 27017, 6379: Conexiones de base de datos
- 9003, 5678, 9229: Puertos de debugging

**Organización de Proyectos:**
- PHP: `~/dev/docker/php-projects/`, `~/dev/docker/php-personal/`, `~/dev/docker/php-work/`
- Python: `~/dev/docker/python-projects/`, `~/dev/docker/python-personal/`, `~/dev/docker/python-work/`
- Node.js: `~/dev/docker/node-projects/`, `~/dev/docker/node-personal/`, `~/dev/docker/node-work/`
- Nginx: `~/dev/docker/nginx-html/`

**Configuración de Debugging:**
- PHP: Xdebug en puerto 9003
- Python: debugpy en puerto 5678
- Node.js: Inspector en puerto 9229

**Frameworks Pre-instalados:**
- PHP: Xdebug habilitado
- Python: Flask, Django, FastAPI, Jupyter
- Node.js: Angular CLI, Vue CLI, React, TypeScript

**Mejores Prácticas de Desarrollo:**
1. Siempre usa `./up.sh` para iniciar el entorno
2. Los datos se persisten automáticamente entre reinicios
3. Revisa los logs si ocurren problemas: `docker-compose logs`
4. Solo para desarrollo local - no para uso en producción
5. Reinicia Apache si cambias la configuración de PHP
6. Usa la bandera `--reload` para recarga automática en frameworks Python
7. Usa `nodemon` para recarga automática en desarrollo Node.js

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

## Estructura de Documentación

```
├── docs/                 # Documentación
│   ├── ARCHITECTURE.md   # Documentación técnica
│   └── WORKFLOW.md       # Guía de flujo de trabajo diario
└── README.md             # Documentación principal
```

- **README.md** - Documentación principal y guía de inicio rápido
- **docs/ARCHITECTURE.md** - Arquitectura detallada del sistema
- **docs/WORKFLOW.md** - Flujo de trabajo diario y patrones de uso

## Notas Importantes

- Todos los servicios usan **Traefik** como proxy reverso para URLs limpias
- **MailHog** captura todos los emails enviados desde tus aplicaciones
- **Credenciales de base de datos** están configuradas para desarrollo (no producción)
- **Permisos de archivos** son manejados automáticamente por Docker
- **Recarga en caliente** está habilitada para todos los servicios de desarrollo

## Solución de Problemas

### Problemas Comunes
1. **Conflictos de puertos:** Detén otros servicios que usen los puertos 80, 3306, 5432, 6379
2. **Problemas de permisos:** Asegúrate de que Docker tenga acceso a los directorios del proyecto
3. **Servicio no inicia:** Revisa los logs con `docker-compose logs [servicio]`
4. **Conexión de base de datos:** Verifica credenciales y asegúrate de que el servicio de base de datos esté corriendo

### Comandos Útiles
```bash
# Verificar estado de servicios
docker-compose ps

# Ver logs de servicio específico
docker-compose logs -f [nombre_servicio]

# Reiniciar servicio específico
docker-compose restart [nombre_servicio]

# Reconstruir contenedores
docker-compose build --no-cache

# Limpiar
docker system prune -a
```

---

**Autor:** nunezlagos  
**Creado para desarrolladores que quieren simplicidad y poder.**
