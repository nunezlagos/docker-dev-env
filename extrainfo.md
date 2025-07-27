# Información Completa del Entorno Docker

## Índice
- [Requisitos del Sistema](#requisitos-del-sistema)
- [Instalación Paso a Paso](#instalación-paso-a-paso)
- [Estructura de Carpetas](#estructura-de-carpetas)
- [Servicios y Puertos](#servicios-y-puertos)
- [Comandos Útiles](#comandos-útiles)
- [Gestión de Proyectos](#gestión-de-proyectos)
- [Backups y Restauración](#backups-y-restauración)
- [Solución de Problemas](#solución-de-problemas)
- [Arquitectura y Consejos](#arquitectura-y-consejos)

---

## Requisitos del Sistema
- **Sistemas compatibles:** Ubuntu 20.04+, Debian 11+, Arch Linux
- **RAM mínima:** 4GB
- **Espacio libre:** 20GB
- **Internet:** Requerido para instalación

## Instalación Paso a Paso
```bash
# 1. Clona el repositorio y entra a scripts
cd /tmp/
git clone https://github.com/nunezlagos/docker-dev-env.git
cd docker-dev-env/scripts/

# 2. Ejecuta el instalador
chmod +x setup.sh
./setup.sh

# 3. Reinicia tu terminal o ejecuta:
newgrp docker
```

## Estructura de Carpetas
```
~/dev/docker/
├── services/      # Servicios Docker (traefik, stack, nginx, etc.)
├── projects/      # Proyectos de desarrollo (PHP, Node.js, Python, etc.)
├── html/          # Archivos estáticos HTML
├── backups/       # Backups automáticos
├── examples/      # Ejemplos y plantillas
```

## Servicios y Puertos

| Servicio         | URL/Host                | Puerto | Debug | Usuario   | Contraseña | Notas                  |
|-----------------|-------------------------|--------|-------|-----------|------------|------------------------|
| Traefik Panel   | http://localhost:8080   | 8080   | -     | -         | -          | Proxy reverso          |
| phpMyAdmin      | http://localhost:8081   | 8081   | -     | devuser   | devpass    | MySQL                  |
| pgAdmin         | http://localhost:8082   | 8082   | -     | admin@admin.com | admin   | PostgreSQL             |
| Mongo Express   | http://localhost:8083   | 8083   | -     | -         | -          | MongoDB                |
| Redis Commander | http://localhost:8084   | 8084   | -     | -         | -          | Redis                  |
| Adminer         | http://localhost:8087   | 8087   | -     | -         | -          | Universal DB           |
| PHP + Apache    | http://php.localhost    | 8085   | 9003  | -         | -          | Xdebug habilitado      |
| Python          | http://python.localhost | 8000   | 5678  | -         | -          | Flask, Django, FastAPI |
| Node.js         | http://node.localhost   | 3000   | 9229  | -         | -          | Angular, Vue, React    |
| Nginx           | http://nginx.localhost  | 8086   | -     | -         | -          | Archivos estáticos     |
| MailHog         | http://mail.localhost   | 8025   | -     | -         | -          | Pruebas de email       |

## Comandos Útiles

- **Ver contenedores activos:**
  ```bash
  docker ps
  ```
- **Ver logs generales:**
  ```bash
  docker-compose logs
  ```
- **Acceder a un contenedor:**
  ```bash
  docker exec -it stack_php_1 bash
  docker exec -it stack_python_1 bash
  docker exec -it stack_nodejs_1 sh
  ```
- **Detener todos los servicios:**
  ```bash
  ./down.sh
  ```

## Gestión de Proyectos

- **Crear proyecto PHP personal:**
  ```bash
  ./project-manager.sh create php personal mi-proyecto
  ```
- **Crear proyecto Python de trabajo:**
  ```bash
  ./project-manager.sh create python work api-backend
  ```
- **Crear proyecto Angular personal:**
  ```bash
  ./project-manager.sh create angular personal dashboard
  ```
- **Listar proyectos:**
  ```bash
  ./project-manager.sh list
  ```

## Backups y Restauración

- **Backups automáticos:**
  - Se generan archivos `.zip` diarios en `~/dev/docker/backups/` antes de iniciar servicios si no existen para el día.
- **Restaurar backup:**
  ```bash
  unzip backups/backup-fecha.zip -d ~/dev/docker/
  ```

## Solución de Problemas

- **Docker no inicia:**
  - Verifica que el servicio esté activo: `sudo systemctl status docker`
- **Permisos de Docker:**
  - Asegúrate de estar en el grupo docker: `groups $USER`
  - Si no, ejecuta: `sudo usermod -aG docker $USER && newgrp docker`
- **Puertos ocupados:**
  - Cambia los puertos en `.env` o detén servicios en conflicto.
- **Logs de errores:**
  - Usa `docker-compose logs` o revisa logs individuales con `docker logs <container>`

## Arquitectura y Consejos

- **Proxy Traefik:** Centraliza el enrutamiento y SSL para todos los servicios.
- **Servicios modulares:** Agrega/quita servicios editando `services/` y los archivos de configuración.
- **Proyectos organizados:** Usa subcarpetas dentro de `projects/` para separar personales, trabajo, pruebas, etc.
- **Scripts auxiliares:**
  - `setup.sh`: Instalación y preparación del entorno
  - `up.sh`: Levanta todos los servicios, realiza backups automáticos
  - `project-manager.sh`: Crea y gestiona proyectos
- **Ejemplos y plantillas:**
  - Carpeta `examples/` con archivos de ejemplo para PHP, Node.js, Python y HTML

---

¿Dudas? Consulta este archivo o abre un issue en el repositorio.