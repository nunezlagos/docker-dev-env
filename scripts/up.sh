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

# Función para encontrar un puerto disponible
find_available_port() {
    local start_port=$1
    local port=$start_port
    
    while ss -tuln | grep -q ":$port\b" 2>/dev/null || netstat -an 2>/dev/null | grep -q ":$port "; do
        port=$((port + 1))
        if [ $port -gt $((start_port + 100)) ]; then
            echo "Error: No se pudo encontrar un puerto disponible cerca de $start_port"
            exit 1
        fi
    done
    
    echo $port
}

# Función para verificar si un puerto está en uso
check_port() {
    PORT=$1
    # Usamos ss (más moderno que netstat) para verificar si el puerto está en la lista de puertos en escucha
    if ss -tuln | grep -q ":$PORT\b" 2>/dev/null || netstat -an 2>/dev/null | grep -q ":$PORT "; then
        echo "Advertencia: El puerto $PORT está en uso, buscando puerto alternativo..."
        return 1
    fi
    return 0
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

# Verificar y asignar puertos dinámicos
echo "Verificando puertos requeridos..."

# Puertos base deseados
TRAEFIK_PORT=8080
PHPMYADMIN_PORT=8081
PGADMIN_PORT=8082
MONGO_EXPRESS_PORT=8083
REDIS_COMMANDER_PORT=8084
PHP_PORT=8085
PYTHON_PORT=8000
NODEJS_PORT=3000
MAILHOG_SMTP_PORT=1025
MAILHOG_WEB_PORT=8025
ADMINER_PORT=8087

# Verificar y encontrar puertos disponibles
if ! check_port $TRAEFIK_PORT; then
    TRAEFIK_PORT=$(find_available_port $TRAEFIK_PORT)
    echo "Usando puerto alternativo para Traefik: $TRAEFIK_PORT"
fi

if ! check_port $PHPMYADMIN_PORT; then
    PHPMYADMIN_PORT=$(find_available_port $PHPMYADMIN_PORT)
    echo "Usando puerto alternativo para phpMyAdmin: $PHPMYADMIN_PORT"
fi

if ! check_port $PGADMIN_PORT; then
    PGADMIN_PORT=$(find_available_port $PGADMIN_PORT)
    echo "Usando puerto alternativo para pgAdmin: $PGADMIN_PORT"
fi

if ! check_port $MONGO_EXPRESS_PORT; then
    MONGO_EXPRESS_PORT=$(find_available_port $MONGO_EXPRESS_PORT)
    echo "Usando puerto alternativo para Mongo Express: $MONGO_EXPRESS_PORT"
fi

if ! check_port $REDIS_COMMANDER_PORT; then
    REDIS_COMMANDER_PORT=$(find_available_port $REDIS_COMMANDER_PORT)
    echo "Usando puerto alternativo para Redis Commander: $REDIS_COMMANDER_PORT"
fi

if ! check_port $PHP_PORT; then
    PHP_PORT=$(find_available_port $PHP_PORT)
    echo "Usando puerto alternativo para PHP: $PHP_PORT"
fi

if ! check_port $PYTHON_PORT; then
    PYTHON_PORT=$(find_available_port $PYTHON_PORT)
    echo "Usando puerto alternativo para Python: $PYTHON_PORT"
fi

if ! check_port $NODEJS_PORT; then
    NODEJS_PORT=$(find_available_port $NODEJS_PORT)
    echo "Usando puerto alternativo para Node.js: $NODEJS_PORT"
fi

if ! check_port $MAILHOG_SMTP_PORT; then
    MAILHOG_SMTP_PORT=$(find_available_port $MAILHOG_SMTP_PORT)
    echo "Usando puerto alternativo para Mailhog SMTP: $MAILHOG_SMTP_PORT"
fi

if ! check_port $MAILHOG_WEB_PORT; then
    MAILHOG_WEB_PORT=$(find_available_port $MAILHOG_WEB_PORT)
    echo "Usando puerto alternativo para Mailhog Web: $MAILHOG_WEB_PORT"
fi

if ! check_port $ADMINER_PORT; then
    ADMINER_PORT=$(find_available_port $ADMINER_PORT)
    echo "Usando puerto alternativo para Adminer: $ADMINER_PORT"
fi

# Crear archivo temporal con variables de entorno para docker-compose
cat > "$DEV_HOME/.env" << EOF
TRAEFIK_PORT=$TRAEFIK_PORT
PHPMYADMIN_PORT=$PHPMYADMIN_PORT
PGADMIN_PORT=$PGADMIN_PORT
MONGO_EXPRESS_PORT=$MONGO_EXPRESS_PORT
REDIS_COMMANDER_PORT=$REDIS_COMMANDER_PORT
PHP_PORT=$PHP_PORT
PYTHON_PORT=$PYTHON_PORT
NODEJS_PORT=$NODEJS_PORT
MAILHOG_SMTP_PORT=$MAILHOG_SMTP_PORT
MAILHOG_WEB_PORT=$MAILHOG_WEB_PORT
ADMINER_PORT=$ADMINER_PORT
EOF

echo "Iniciando proxy reverso Traefik..."
TRAEFIK_PORT=$TRAEFIK_PORT docker-compose -f "$DEV_HOME/config/traefik-compose.yml" up -d --remove-orphans

echo "Iniciando servicios de desarrollo..."
docker-compose -f "$DEV_HOME/config/stack-compose.yml" --env-file "$DEV_HOME/.env" up -d --remove-orphans
echo ""

echo "Esperando que los servicios estén listos..."
sleep 5

echo "Estado de contenedores:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

echo "Entorno de desarrollo listo!"
echo ""
echo "Servicios disponibles:"
echo "   - Panel Traefik: http://localhost:$TRAEFIK_PORT (Nota: Puede tardar unos minutos en cargar)"
echo "   - Desarrollo PHP: http://php.localhost (Debug: 9003) - Requiere configurar hosts"
echo "   - Desarrollo Python: http://python.localhost (Debug: 5678) - Requiere configurar hosts"
echo "   - Desarrollo Node.js: http://node.localhost (Debug: 9229) - Requiere configurar hosts"

echo "   - Gestor de correo: http://mail.localhost - Requiere configurar hosts"
echo "   - phpMyAdmin: http://localhost:$PHPMYADMIN_PORT"
echo "   - pgAdmin: http://localhost:$PGADMIN_PORT"
echo "   - Mongo Express: http://localhost:$MONGO_EXPRESS_PORT (Usuario: admin, Contraseña: pass)"
echo "   - Redis Commander: http://localhost:$REDIS_COMMANDER_PORT"
echo "   - Adminer: http://localhost:$ADMINER_PORT"
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