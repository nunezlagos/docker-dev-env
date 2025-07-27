#!/bin/bash

# Project Manager for Docker Development Environment
# Author: nunezlagos
# Description: Script to create and manage projects across different technologies
# Version: 2.0
# Usage: ./project-manager.sh [command] [type] [category] [name]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Función para logging
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Configuración
DEV_HOME="$HOME/dev/docker"

# Function to show help
show_help() {
    echo "Project Manager - Docker Development Environment"
    echo "Author: nunezlagos"
    echo ""
    echo "Usage: ./project-manager.sh [command] [type] [category] [name]"
    echo ""
    echo "Commands:"
    echo "  create    - Create a new project"
    echo "  list      - List existing projects"
    echo "  remove    - Remove a project"
    echo "  info      - Show environment information"
    echo "  start     - Start Docker stack"
    echo "  stop      - Stop Docker stack"
    echo "  status    - Show stack status"
    echo "  logs      - Show stack logs"
    echo "  help      - Show this help"
    echo ""
    echo "Project types:"
    echo "  php       - PHP Project"
    echo "  python    - Python Project"
    echo "  node      - Node.js Project"
    echo "  angular   - Angular Project"
    echo "  react     - React Project"
    echo "  vue       - Vue.js Project"
    echo ""
    echo "Categories:"
    echo "  general   - General/test projects"
    echo "  personal  - Personal projects"
    echo "  work      - Work projects"
    echo ""
    echo "Examples:"
    echo "  ./project-manager.sh create php personal mi-blog"
    echo "  ./project-manager.sh create angular work dashboard-admin"
    echo "  ./project-manager.sh create python personal api-rest"
    echo "  ./project-manager.sh list php"
    echo "  ./project-manager.sh start"
    echo "  ./project-manager.sh info"
}

# Función para verificar si Docker está corriendo
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        error "Docker no está corriendo. Por favor, inicia Docker primero."
        exit 1
    fi
}

# Función para crear proyecto PHP
create_php_project() {
    local category=$1
    local name=$2
    local project_path="$DEV_HOME/php-$category/$name"
    
    mkdir -p "$project_path"
    
    cat > "$project_path/index.php" << EOF
<?php
// Proyecto: $name
// Categoría: $category
// Creado: $(date)

echo "<h1>Proyecto PHP: $name</h1>";
echo "<p>Categoría: $category</p>";
echo "<p>Debugging habilitado en puerto 9003</p>";
echo "<p>Acceso: http://localhost:8085/$category/$name</p>";

// Tu código aquí...
?>
EOF

    log "Proyecto PHP '$name' creado en: $project_path"
    info "Acceso: http://localhost:8085/$category/$name"
}

# Función para crear proyecto Python
create_python_project() {
    local category=$1
    local name=$2
    local project_path="$DEV_HOME/python-$category/$name"
    
    mkdir -p "$project_path"
    
    cat > "$project_path/main.py" << EOF
# Project: $name
# Category: $category
# Created: $(date)
# Author: nunezlagos

print(f"Python Project: $name")
print(f"Category: $category")
print(f"Debugging available on port 5678")
print(f"For Flask: flask run --host=0.0.0.0 --port=8000")
print(f"For FastAPI: uvicorn main:app --host 0.0.0.0 --port 8000 --reload")

# Tu código aquí...
if __name__ == "__main__":
    print("¡Hola desde Python!")
EOF

    cat > "$project_path/requirements.txt" << EOF
# Dependencias del proyecto $name
flask
fastapi
uvicorn
requests
EOF

    log "Proyecto Python '$name' creado en: $project_path"
    info "Acceso al contenedor: docker exec -it stack_python_1 bash"
    info "Navegar a: cd $category/$name"
}

# Función para crear proyecto Node.js
create_node_project() {
    local category=$1
    local name=$2
    local project_path="$DEV_HOME/node-$category/$name"
    
    mkdir -p "$project_path"
    
    cat > "$project_path/package.json" << EOF
{
  "name": "$name",
  "version": "1.0.0",
  "description": "Proyecto Node.js - $category",
  "main": "app.js",
  "scripts": {
    "start": "node app.js",
    "dev": "nodemon --inspect=0.0.0.0:9229 app.js"
  },
  "dependencies": {
    "express": "^4.18.0"
  },
  "devDependencies": {
    "nodemon": "^3.0.0"
  }
}
EOF

    cat > "$project_path/app.js" << EOF
// Project: $name
// Category: $category
// Created: $(date)
// Author: nunezlagos

const express = require('express');
const app = express();
const PORT = 3000;

app.get('/', (req, res) => {
    res.send(\`
        <h1>Node.js Project: $name</h1>
        <p>Category: $category</p>
        <p>Author: nunezlagos</p>
        <p>Debugging available on port 9229</p>
        <p>Access: http://localhost:3000</p>
    \`);
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(\`Server running on http://localhost:\${PORT}\`);
    console.log(\`Debugging enabled on port 9229\`);
});
EOF

    log "Proyecto Node.js '$name' creado en: $project_path"
    info "Acceso al contenedor: docker exec -it stack_nodejs_1 sh"
    info "Navegar a: cd $category/$name"
    info "Instalar dependencias: npm install"
    info "Ejecutar: npm run dev"
}

# Función para crear proyecto Angular
create_angular_project() {
    local category=$1
    local name=$2
    
    log "Creando proyecto Angular '$name' en categoría '$category'..."
    info "Esto puede tomar unos minutos..."
    
    docker exec -it stack_nodejs_1 sh -c "cd $category && ng new $name --routing --style=css --skip-git && cd $name && ng serve --host 0.0.0.0 --port 3000" &
    
    log "Proyecto Angular '$name' en proceso de creación"
    info "Acceso: http://localhost:3000 (una vez completado)"
}

# Function to list projects
list_projects() {
    local type=$1
    
    echo "$type Projects:"
    echo ""
    
    for category in general personal work; do
        local path="$DEV_HOME/$type-$category"
        if [ -d "$path" ]; then
            echo "$category:"
            if [ "$(ls -A $path 2>/dev/null)" ]; then
                ls -la "$path" | grep "^d" | awk '{print "  - " $9}' | grep -v "^  - \.$" | grep -v "^  - \.\.$"
            else
                echo "  (empty)"
            fi
            echo ""
        fi
    done
}

# Function to show environment information
show_info() {
    echo "Development Environment Information"
    echo "Author: nunezlagos"
    echo ""
    echo "Container Status:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(NAMES|stack_|traefik)"
    echo ""
    echo "Folder Structure:"
    tree "$DEV_HOME" -L 2 2>/dev/null || find "$DEV_HOME" -maxdepth 2 -type d
    echo ""
    echo "Access URLs:"
    echo "  - PHP: http://localhost:8085"
    echo "  - Python: http://localhost:8000"
    echo "  - Node.js: http://localhost:3000"
    echo "  - Nginx: http://localhost:8086"
    echo "  - MailHog: http://localhost:8025"
    echo "  - Traefik: http://localhost:8080"
    echo ""
    echo "Debugging Ports:"
    echo "  - PHP (Xdebug): 9003"
    echo "  - Python (debugpy): 5678"
    echo "  - Node.js (Inspector): 9229"
}

# Función principal
main() {
    case "$1" in
        "create")
            check_docker
            case "$2" in
                "php")
                    create_php_project "$3" "$4"
                    ;;
                "python")
                    create_python_project "$3" "$4"
                    ;;
                "node")
                    create_node_project "$3" "$4"
                    ;;
                "angular")
                    create_angular_project "$3" "$4"
                    ;;
                "react")
                    docker exec -it stack_nodejs_1 sh -c "cd $3 && npx create-react-app $4 && cd $4 && npm start"
                    ;;
                "vue")
                    docker exec -it stack_nodejs_1 sh -c "cd $3 && vue create $4 && cd $4 && npm run serve"
                    ;;
                *)
                    error "Tipo de proyecto no válido: $2"
                    show_help
                    exit 1
                    ;;
            esac
            ;;
        "list")
            list_projects "$2"
            ;;
        "start")
            log "Iniciando stack de desarrollo..."
            docker-compose -f config/stack-compose.yml up -d
            ;;
        "stop")
            log "Deteniendo stack de desarrollo..."
            docker-compose -f config/stack-compose.yml down
            ;;
        "status")
            docker-compose -f config/stack-compose.yml ps
            ;;
        "logs")
            docker-compose -f config/stack-compose.yml logs -f
            ;;
        "info")
            show_info
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            error "Comando no válido: $1"
            show_help
            exit 1
            ;;
    esac
}

# Verificar argumentos
if [ $# -eq 0 ]; then
    show_help
    exit 1
fi

# Ejecutar función principal
main "$@"