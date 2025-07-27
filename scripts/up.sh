#!/bin/bash

# Docker Development Environment Startup Script
# Author: nunezlagos
# Description: Starts all development environment services

set -e

echo "Starting Docker development environment..."
echo ""

# Verificar que Docker esté corriendo
if ! docker info >/dev/null 2>&1; then
    echo "Error: Docker is not running"
    echo "Start Docker with: sudo systemctl start docker"
    exit 1
fi

# Verificar que estemos en el grupo docker
if ! groups $USER | grep -qw docker; then
    echo "Warning: You are not in the docker group"
    echo "Run: newgrp docker"
fi

# Ir al directorio de desarrollo
DEV_HOME="$HOME/dev/docker"
if [ ! -d "$DEV_HOME" ]; then
    echo "Error: Directory $DEV_HOME does not exist"
    echo "Run first: ./setup.sh"
    exit 1
fi

cd "$DEV_HOME"

echo "Working in: $DEV_HOME"
echo ""

# Verificar que existan los archivos docker-compose
if [ ! -f "traefik/docker-compose.yml" ]; then
    echo "Error: traefik/docker-compose.yml not found"
    exit 1
fi

if [ ! -f "stack/docker-compose.yml" ]; then
    echo "Error: stack/docker-compose.yml not found"
    exit 1
fi

# Verificar que la red traefik exista
if ! docker network ls | grep -qw traefik; then
    echo "Creating traefik network..."
    docker network create traefik
fi

echo "Starting Traefik reverse proxy..."
docker-compose -f config/traefik-compose.yml up -d

echo "Starting development services..."
docker-compose -f config/stack-compose.yml up -d
echo ""

echo "Waiting for services to be ready..."
sleep 5

echo "Container status:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

echo "Development environment ready!"
echo ""
echo "Available services:"
echo "   - Traefik Dashboard: http://localhost:8080"
echo "   - PHP Development: http://php.localhost (Debug: 9003)"
echo "   - Python Development: http://python.localhost (Debug: 5678)"
echo "   - Node.js Development: http://node.localhost (Debug: 9229)"
echo "   - Static Files (Nginx): http://static.localhost (optional)"
echo "   - Mail handler: http://mail.localhost"
echo "   - Adminer: http://localhost:8081"
echo "   - phpMyAdmin: http://localhost:8082"
echo "   - Mongo Express: http://localhost:8083"
echo "   - Redis Commander: http://localhost:8084"
echo ""
echo "Project folders:"
echo "   PHP General: ~/dev/docker/php-projects/"
echo "   PHP Personal: ~/dev/docker/php-personal/"
echo "   PHP Work: ~/dev/docker/php-work/"
echo "   Node.js General: ~/dev/docker/node-projects/"
echo "   Node.js Personal: ~/dev/docker/node-personal/"
echo "   Node.js Work: ~/dev/docker/node-work/"
echo "   Python General: ~/dev/docker/python-projects/"
echo "   Python Personal: ~/dev/docker/python-personal/"
echo "   Python Work: ~/dev/docker/python-work/"
echo "   Nginx: ~/dev/docker/nginx-html/"
echo ""
echo "To stop: docker-compose -f stack/docker-compose.yml down && docker-compose -f traefik/docker-compose.yml down"
echo "To view logs: docker-compose -f stack/docker-compose.yml logs"