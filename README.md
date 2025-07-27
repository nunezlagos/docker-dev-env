# Entorno de Desarrollo Docker

**Autor:** nunezlagos

## Guía Rápida

### Instalación

1.  Clona el repositorio:
    ```bash
    git clone https://github.com/nunezlagos/docker-dev-env.git
    cd docker-dev-env
    ```

2.  Ejecuta el script de instalación:
    ```bash
    bash setup.sh
    ```

### Uso Básico

-   **Iniciar entorno:** `cd ~/dev/docker && ./up.sh`
-   **Crear un proyecto:** `./project-manager.sh create php mi-proyecto`
-   **Detener entorno:** `docker-compose down`

### Organización de Proyectos

-   `~/dev/docker/services`: Para configuraciones de servicios (Traefik, etc.).
-   `~/dev/docker/projects`: Para tus proyectos PHP, Node, Python, etc.
-   `~/dev/docker/html`: Para proyectos estáticos HTML/Nginx.

### Estructura de Carpetas Generada

```
~/dev/docker/
├── services/
├── projects/
└── html/
```

Para información más detallada, consulta [extrainfo.md](./docs/extrainfo.md).
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

### Datos de Conexión para Bases de Datos

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

### Cómo Usar los Servidores de Desarrollo

### Organización de Proyectos
La estructura de carpetas principal es:
- `~/dev/docker/projects/`: Contiene todos tus proyectos, organizados por tecnología y categoría (ej: `projects/php/personal/mi-proyecto`).
- `~/dev/docker/services/`: Contiene la configuración de los servicios de Docker.
- `~/dev/docker/html/`: Para archivos estáticos servidos por Nginx.
- `~/dev/docker/backups/`: Donde se guardan las copias de seguridad.

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

# Eliminar un proyecto
./project-manager.sh delete php personal mi-blog

# Ver estado del entorno
./project-manager.sh info
```

### Estructura de Carpetas Generada:

La estructura de carpetas optimizada que crea `setup.sh` es:

```
~/dev/docker/
├── services/
├── projects/
│   ├── php/
│   │   ├── personal/
│   │   └── work/
│   ├── node/
│   └── python/
├── html/
├── nginx-html/
├── backups/
└── examples/
```

Esta estructura centraliza todos los proyectos en la carpeta `projects`, simplificando la gestión.

## Comandos de Uso Básico

### Gestión del Entorno

```bash
# Iniciar todos los servicios
./up.sh

# Detener todos los servicios
./down.sh

# Ver estado de servicios
./project-manager.sh status

# Ver logs
./project-manager.sh logs

# Reiniciar servicios
./project-manager.sh restart

# Iniciar solo servidor estático (Nginx)
# (Funcionalidad avanzada, editar docker-compose.yml si es necesario)
# docker-compose --profile static up nginx
```

### Gestión de Proyectos (Nuevo)
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

### Reiniciar un Servicio Específico
```bash
# Reiniciar MySQL
docker-compose -f stack-compose.yml restart mysql

# Reiniciar PostgreSQL
docker-compose -f stack-compose.yml restart postgres

# Reiniciar MongoDB
docker-compose -f stack-compose.yml restart mongodb
```

### Ver el Estado de los Servicios
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

### Ver Logs (Para Solucionar Problemas)
```bash
# Ver logs de todos los servicios
docker-compose -f stack-compose.yml logs

# Ver logs de un servicio específico
docker-compose -f stack-compose.yml logs mysql

# Ver logs en tiempo real
docker-compose -f stack-compose.yml logs -f
```

## Solución de Problemas Comunes

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
- **phpMyAdmin:** Puerto 8081
- **pgAdmin:** Puerto 8082
- **Mongo Express:** Puerto 8083
- **Redis Commander:** Puerto 8084
- **Adminer:** Puerto 8087

### Consejos de Desarrollo

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

### Solución de Problemas

**Problemas Comunes:**

1. **"Puerto ya en uso"**
   ```bash
   # Revisa qué está usando el puerto
   sudo lsof -i :8080
   # Termina el proceso
   sudo kill -9 [PID]
   ```

2. **"No se puede conectar a Docker"**
   ```bash
   # Reinicia Docker
   sudo systemctl restart docker
   # Agrega el usuario al grupo de docker
   sudo usermod -aG docker $USER
   ```

3. **"El contenedor no arranca"**
   ```bash
   # Ver logs detallados
   docker-compose logs [nombre-del-servicio]
   ```

**Comandos Útiles:**
```bash
# Limpiar todo Docker (¡PRECAUCIÓN!)
docker system prune -a

# Ver uso de espacio
docker system df

# Actualizar imágenes
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
