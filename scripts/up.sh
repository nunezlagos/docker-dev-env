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
    # Usamos ss (más moderno que netstat) para verificar si el puerto está en la lista de puertos en escucha
    if ss -tuln | grep -q ":$PORT\b"; then
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

# --- NUEVO: Limpiar contenedores y volúmenes huérfanos ---
echo "Limpiando contenedores y volúmenes huérfanos..."

# Detener todos los contenedores relacionados con config
CONFIG_CONTAINERS=$(docker ps -a --format '{{.Names}}' | grep "^config_" || true)
if [ -n "$CONFIG_CONTAINERS" ]; then
    echo "Deteniendo contenedores config existentes..."
    docker stop $CONFIG_CONTAINERS 2>/dev/null || true
    docker rm $CONFIG_CONTAINERS 2>/dev/null || true
fi

# Limpiar volúmenes huérfanos
echo "Limpiando volúmenes huérfanos..."
docker volume prune -f 2>/dev/null || true

# Limpiar redes huérfanas
echo "Limpiando redes huérfanas..."
docker network prune -f 2>/dev/null || true

echo "Limpieza completada."
# --- FIN NUEVO ---


# Verificar que existan los archivos docker-compose
if [ ! -f "config/traefik-compose.yml" ]; then
    echo "Error: config/traefik-compose.yml no encontrado"
    exit 1
fi

if [ ! -f "config/stack-compose.yml" ]; then
    echo "Error: config/stack-compose.yml no encontrado"
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
docker-compose -f "$DEV_HOME/config/traefik-compose.yml" up -d --remove-orphans

echo "Iniciando servicios de desarrollo..."
docker-compose -f "$DEV_HOME/config/stack-compose.yml" up -d --remove-orphans
echo ""

echo "Esperando que los servicios estén listos..."
sleep 5

echo "Estado de contenedores:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

echo "Entorno de desarrollo listo!"
echo ""
echo "Servicios disponibles:"
echo "   - Panel Traefik: http://localhost:8080 (Nota: Puede tardar unos minutos en cargar)"
echo "   - Desarrollo PHP: http://php.localhost (Debug: 9003) - Requiere configurar hosts"
echo "   - Desarrollo Python: http://python.localhost (Debug: 5678) - Requiere configurar hosts"
echo "   - Desarrollo Node.js: http://node.localhost (Debug: 9229) - Requiere configurar hosts"

echo "   - Gestor de correo: http://mail.localhost - Requiere configurar hosts"
echo "   - phpMyAdmin: http://localhost:8081"
echo "   - pgAdmin: http://localhost:8082"
echo "   - Mongo Express: http://localhost:8083 (Usuario: admin, Contraseña: pass)"
echo "   - Redis Commander: http://localhost:8084"
echo "   - Adminer: http://localhost:8087"
echo ""
echo "Carpetas de proyectos:"
echo "   Proyectos: ~/dev/docker/projects/"
echo "   Servicios: ~/dev/docker/services/"
echo "   HTML: ~/dev/docker/html/"
echo ""
echo "NOTA IMPORTANTE para dominios .localhost:"
echo "Para que funcionen los servicios con dominios .localhost, necesitas agregar estas líneas"
echo "al archivo hosts de tu sistema:"
echo ""
echo "En Windows: C:\\Windows\\System32\\drivers\\etc\\hosts"
echo "En Linux/Mac: /etc/hosts"
echo ""
echo "Agregar estas líneas:"
echo "127.0.0.1 php.localhost"
echo "127.0.0.1 python.localhost"
echo "127.0.0.1 node.localhost"
echo "127.0.0.1 static.localhost"
echo "127.0.0.1 mail.localhost"
echo ""
echo "Para detener: docker-compose -f stack/docker-compose.yml down && docker-compose -f traefik/docker-compose.yml down"
echo "Para ver logs: docker-compose -f stack/docker-compose.yml logs"