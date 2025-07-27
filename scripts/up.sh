#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

# Script de Inicio del Entorno de Desarrollo Docker
# Autor: nunezlagos
# Descripción: Inicia todos los servicios del entorno de desarrollo
# Modularizado: Lógica delegada a sub-scripts en scripts/sub-scripts/

set -e

echo "Iniciando entorno de desarrollo Docker..."
echo ""

# Verificar que Docker esté corriendo
if ! docker info >/dev/null 2>&1; then
    echo "Error: Docker no está corriendo"
    echo "Iniciar Docker con: sudo systemctl start docker"
    exit 1
fi

# Verificar que estemos en el grupo docker
if ! groups $USER | grep -qw docker; then
    echo "Advertencia: No estás en el grupo docker"
    echo "Ejecutar: newgrp docker"
fi

# Función para verificar si un puerto está en uso
check_port() {
    PORT=$1
    # Usamos netstat y grep para verificar si el puerto está en la lista de puertos en escucha
    if netstat -tuln | grep -q ":$PORT\b"; then
        echo "Error: El puerto $PORT ya está en uso."
        echo "Por favor, detenga el servicio que usa este puerto o cambie la configuración en config/stack-compose.yml."
        exit 1
    fi
}

# Ir al directorio de desarrollo
DEV_HOME="$HOME/dev/docker"
if [ ! -d "$DEV_HOME" ]; then
    echo "Error: El directorio $DEV_HOME no existe"
    echo "Ejecutar primero: ./setup.sh"
    exit 1
fi

cd "$DEV_HOME"

echo "Trabajando en: $DEV_HOME"
echo ""

# --- NUEVO: Apagar contenedores previos y backup automático ---
FUTURE_PREFIX="stack_"
BACKUP_DIR="$DEV_HOME/backups"
BACKUP_FILE="$BACKUP_DIR/backup_$(date +%Y%m%d).zip"

mkdir -p "$BACKUP_DIR"

# Listar contenedores que coincidan con el prefijo
EXISTING_CONTAINERS=$(docker ps -a --format '{{.Names}}' | grep "^$FUTURE_PREFIX" || true)
if [ -n "$EXISTING_CONTAINERS" ]; then
    echo "Se encontraron contenedores previos con el prefijo '$FUTURE_PREFIX'."
    echo "Deteniendo y eliminando contenedores previos..."
    docker stop $EXISTING_CONTAINERS
    docker rm $EXISTING_CONTAINERS
    echo "Contenedores detenidos y eliminados."
    # Verificar si hay datos persistentes
    echo "Verificando posibles volúmenes y datos asociados..."
    # Listar volúmenes asociados a los servicios
    VOLUMENES=$(docker volume ls --format '{{.Name}}' | grep "$FUTURE_PREFIX" || true)
    if [ -n "$VOLUMENES" ]; then
        echo "ADVERTENCIA: Se detectaron volúmenes asociados que podrían contener datos de bases de datos u otros servicios."
        echo "Se recomienda realizar un backup antes de continuar."
    fi
    # Backup automático si no existe
    if [ ! -f "$BACKUP_FILE" ]; then
        echo "Realizando backup de datos persistentes en $BACKUP_FILE ..."
        if command -v zip >/dev/null; then
            zip -r "$BACKUP_FILE" "$DEV_HOME/services" "$DEV_HOME/projects" "$DEV_HOME/html" 2>/dev/null
            echo "Backup creado en $BACKUP_FILE."
        else
            echo "ERROR: zip no está instalado. Instale zip para backups automáticos."
        fi
    else
        echo "Ya existe un backup para hoy en $BACKUP_FILE."
    fi
fi
# --- FIN NUEVO ---


# Verificar que existan los archivos docker-compose
if [ ! -f "traefik/docker-compose.yml" ]; then
    echo "Error: traefik/docker-compose.yml no encontrado"
    exit 1
fi

if [ ! -f "stack/docker-compose.yml" ]; then
    echo "Error: stack/docker-compose.yml no encontrado"
    exit 1
fi

# Verificar que la red traefik exista
if ! docker network ls | grep -qw traefik; then
    echo "Creando red traefik..."
    docker network create traefik
fi

# Verificar puertos antes de iniciar
echo "Verificando puertos requeridos..."
check_port 8080 # Traefik UI
check_port 8081 # phpMyAdmin
check_port 8082 # pgAdmin
check_port 8083 # Mongo Express
check_port 8084 # Redis Commander
check_port 8085 # PHP
check_port 8000 # Python
check_port 3000 # Node.js
check_port 1025 # Mailhog SMTP
check_port 8025 # Mailhog Web
check_port 8087 # Adminer

echo "Iniciando proxy reverso Traefik..."
docker-compose -f "$DEV_HOME/traefik/docker-compose.yml" up -d

echo "Iniciando servicios de desarrollo..."
docker-compose -f "$DEV_HOME/stack/docker-compose.yml" up -d
echo ""

echo "Esperando que los servicios estén listos..."
sleep 5

echo "Estado de contenedores:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

echo "Entorno de desarrollo listo!"
echo ""
echo "Servicios disponibles:"
echo "   - Panel Traefik: http://localhost:8080"
echo "   - Desarrollo PHP: http://php.localhost (Debug: 9003)"
echo "   - Desarrollo Python: http://python.localhost (Debug: 5678)"
echo "   - Desarrollo Node.js: http://node.localhost (Debug: 9229)"
echo "   - Archivos Estáticos (Nginx): http://static.localhost (opcional)"
echo "   - Gestor de correo: http://mail.localhost"
echo "   - phpMyAdmin: http://localhost:8081"
echo "   - pgAdmin: http://localhost:8082"
echo "   - Mongo Express: http://localhost:8083"
echo "   - Redis Commander: http://localhost:8084"
echo "   - Adminer: http://localhost:8087"
echo ""
echo "Carpetas de proyectos:"
echo "   PHP General: ~/dev/docker/php-projects/"
echo "   PHP Personal: ~/dev/docker/php-personal/"
echo "   PHP Trabajo: ~/dev/docker/php-work/"
echo "   Node.js General: ~/dev/docker/node-projects/"
echo "   Node.js Personal: ~/dev/docker/node-personal/"
echo "   Node.js Trabajo: ~/dev/docker/node-work/"
echo "   Python General: ~/dev/docker/python-projects/"
echo "   Python Personal: ~/dev/docker/python-personal/"
echo "   Python Trabajo: ~/dev/docker/python-work/"
echo "   Nginx: ~/dev/docker/nginx-html/"
echo ""
echo "Para detener: docker-compose -f stack/docker-compose.yml down && docker-compose -f traefik/docker-compose.yml down"
echo "Para ver logs: docker-compose -f stack/docker-compose.yml logs"