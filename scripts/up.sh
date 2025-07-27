#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

# Script de Inicio del Entorno de Desarrollo Docker
# Autor: nunezlagos
# Descripción: Inicia todos los servicios del entorno de desarrollo

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

echo "Iniciando proxy reverso Traefik..."
docker-compose -f "$SCRIPT_DIR/../config/traefik-compose.yml" up -d

echo "Iniciando servicios de desarrollo..."
docker-compose -f "$SCRIPT_DIR/../config/stack-compose.yml" up -d
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
echo "   - Adminer: http://localhost:8081"
echo "   - phpMyAdmin: http://localhost:8082"
echo "   - Mongo Express: http://localhost:8083"
echo "   - Redis Commander: http://localhost:8084"
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