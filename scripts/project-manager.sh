#!/bin/bash

# Gestor de Proyectos para Entorno de Desarrollo Docker
# Autor: nunezlagos
# Descripción: Script para crear y gestionar proyectos en diferentes tecnologías
# Versión: 2.0
# Uso: ./project-manager.sh [comando] [tipo] [categoría] [nombre]

set -e

# Colores para salida
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # Sin Color

# Función para logging
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[AVISO]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Configuración
DEV_HOME="$HOME/dev/docker"
PROJECTS_HOME="$DEV_HOME/projects"

# Función para mostrar ayuda
show_help() {
    echo "Gestor de Proyectos - Entorno de Desarrollo Docker"
    echo "Autor: nunezlagos"
    echo ""
    echo "Uso: ./project-manager.sh [comando] [tipo] [nombre]"
    echo ""
    echo "Comandos:"
    echo "  create    - Crear un nuevo proyecto"
    echo "  list      - Listar proyectos existentes"
    echo "  remove    - Eliminar un proyecto"
    echo "  info      - Mostrar información del entorno"
    echo "  start     - Iniciar stack Docker"
    echo "  stop      - Detener stack Docker"
    echo "  status    - Mostrar estado del stack"
    echo "  logs      - Mostrar logs del stack"
    echo "  help      - Mostrar esta ayuda"
    echo ""
    echo "Tipos de proyecto:"
    echo "  php       - Proyecto PHP"
    echo "  python    - Proyecto Python"
    echo "  node      - Proyecto Node.js"
    echo ""
    echo "Ejemplos:"
    echo "  ./project-manager.sh create php mi-blog"
    echo "  ./project-manager.sh create python api-rest"
    echo "  ./project-manager.sh list"
    echo "  ./project-manager.sh delete php mi-blog"
    echo "  ./project-manager.sh start"
    echo "  ./project-manager.sh info"
}

# Función para verificar estado de Docker
check_docker_status() {
    if ! command -v docker &> /dev/null; then
        error "Docker no está instalado o no está en PATH"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        error "Docker no está ejecutándose. Por favor inicia Docker primero."
        exit 1
    fi
    
    log "Docker está funcionando correctamente"
}

# Función para crear proyecto PHP
create_php_project() {
    local name="$1"
    local project_path="$PROJECTS_HOME/$name"
    
    log "Creando proyecto PHP: $name"
    
    # Crear estructura de directorios
    mkdir -p "$project_path/public"
    mkdir -p "$project_path/src"
    mkdir -p "$project_path/config"
    
    # Crear index.php
    cat > "$project_path/public/index.php" << 'EOF'
<?php
// Proyecto PHP: $name
// Creado con Entorno de Desarrollo Docker

// Configuración básica
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Incluir autoloader si usas Composer
// require_once __DIR__ . '/../vendor/autoload.php';

?>
EOF

    log "Proyecto PHP '$name' creado en: $project_path"
    info "Acceso: http://localhost:8085/$category/$name"
}

# Función para crear proyecto Python
create_python_project() {
    local category="$1"
    local name="$2"
    local project_path="$DEV_HOME/$category/python/$name"
    
    log "Creando proyecto Python: $name en categoría: $category"
    
    # Crear estructura de directorios
    mkdir -p "$project_path"
    
    # Crear main.py
    cat > "$project_path/main.py" << 'EOF'
# Proyecto Python: $name
# Creado con Entorno de Desarrollo Docker
# Autor: nunezlagos

print(f"Proyecto Python: $name")
print(f"Categoría: $category")
print(f"Debugging disponible en puerto 5678")
print(f"Para Flask: flask run --host=0.0.0.0 --port=8000")
print(f"Para FastAPI: uvicorn main:app --host 0.0.0.0 --port=8000 --reload")

# Tu código aquí...
if __name__ == "__main__":
    print("¡Hola desde Python!")
EOF

    # Crear requirements.txt
    cat > "$project_path/requirements.txt" << 'EOF'
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
    local category="$1"
    local name="$2"
    local project_path="$DEV_HOME/$category/node/$name"
    
    log "Creando proyecto Node.js: $name en categoría: $category"
    
    # Crear estructura de directorios
    mkdir -p "$project_path"
    
    # Crear package.json
    cat > "$project_path/package.json" << 'EOF'
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

    # Crear app.js
    cat > "$project_path/app.js" << 'EOF'
// Proyecto Node.js: $name
// Creado con Entorno de Desarrollo Docker
// Autor: nunezlagos

const express = require('express');
const app = express();
const PORT = 3000;

app.get('/', (req, res) => {
    res.send(`
        <h1>Proyecto Node.js: $name</h1>
        <p>Categoría: $category</p>
        <p>Autor: nunezlagos</p>
        <p>Debugging disponible en puerto 9229</p>
        <p>Acceso: http://localhost:3000</p>
    `);
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Servidor ejecutándose en http://localhost:${PORT}`);
    console.log(`Debugging habilitado en puerto 9229`);
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
    local category="$1"
    local name="$2"
    local project_path="$DEV_HOME/$category/node/$name"

    if [ -d "$project_path" ]; then
        error "El proyecto '$name' ya existe en '$project_path'"
        exit 1
    fi
    
    log "Creando proyecto Angular '$name' en categoría '$category'..."
    info "Esto puede tomar unos minutos..."
    
    docker exec -it stack_nodejs_1 sh -c "cd /var/www/node-projects/$category && ng new $name --routing --style=css --skip-git"
    
    log "Proyecto Angular '$name' creado."
    info "Para iniciarlo, accede al contenedor y ejecuta:"
    info "  cd /var/www/node-projects/$category/$name && ng serve --host 0.0.0.0 --port 3000"
}

# Función para crear proyecto React
create_react_project() {
    local category="$1"
    local name="$2"
    local project_path="$DEV_HOME/$category/node/$name"

    if [ -d "$project_path" ]; then
        error "El proyecto '$name' ya existe en '$project_path'"
        exit 1
    fi
    
    log "Creando proyecto React '$name' en categoría '$category'..."
    info "Esto puede tomar unos minutos..."
    
    docker exec -it stack_nodejs_1 sh -c "cd /var/www/node-projects/$category && npx create-react-app $name"
    
    log "Proyecto React '$name' creado."
    info "Para iniciarlo, accede al contenedor y ejecuta:"
    info "  cd /var/www/node-projects/$category/$name && npm start"
}

# Función para crear proyecto Vue
create_vue_project() {
    local category="$1"
    local name="$2"
    local project_path="$DEV_HOME/$category/node/$name"

    if [ -d "$project_path" ]; then
        error "El proyecto '$name' ya existe en '$project_path'"
        exit 1
    fi
    
    log "Creando proyecto Vue '$name' en categoría '$category'..."
    info "Esto puede tomar unos minutos..."
    
    docker exec -it stack_nodejs_1 sh -c "cd /var/www/node-projects/$category && vue create $name --default"
    
    log "Proyecto Vue '$name' creado."
    info "Para iniciarlo, accede al contenedor y ejecuta:"
    info "  cd /var/www/node-projects/$category/$name && npm run serve"
}

# Función para eliminar un proyecto
delete_project() {
    local type="$1"
    local category="$2"
    local name="$3"
    local project_path=""

    case "$type" in
        "php")
            project_path="$DEV_HOME/$category/php/$name"
            ;;
        "python")
            project_path="$DEV_HOME/$category/python/$name"
            ;;
        "node" | "angular" | "react" | "vue")
            project_path="$DEV_HOME/$category/node/$name"
            ;;
        *)
            error "Tipo de proyecto no válido: $type"
            exit 1
            ;;
    esac

    if [ ! -d "$project_path" ]; then
        error "El proyecto '$name' no existe en '$project_path'"
        exit 1
    fi

    info "¿Estás seguro de que deseas eliminar el proyecto '$name' en '$project_path'?"
    read -p "Escribe 'si' para confirmar: " confirmation

    if [ "$confirmation" == "si" ]; then
        log "Eliminando proyecto '$name'..."
        rm -rf "$project_path"
        log "Proyecto '$name' eliminado."
    else
        info "Eliminación cancelada."
    fi
}

# Función para listar proyectos
list_projects() {
    local type="$1"
    
    echo "Proyectos $type:"
    echo ""
    
    for category in general personal work; do
        local path="$DEV_HOME/$category/$type"
        if [ -d "$path" ]; then
            echo "$category:"
            if [ "$(ls -A $path 2>/dev/null)" ]; then
                ls -la "$path" | grep "^d" | awk '{print "  - " $9}' | grep -v "^  - \.$" | grep -v "^  - \.\.$"
            else
                echo "  (vacío)"
            fi
            echo ""
        fi
    done
}

# Función para mostrar información del entorno
show_info() {
    echo "Información del Entorno de Desarrollo"
    echo "Autor: nunezlagos"
    echo ""
    echo "Estado de Contenedores:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(NAMES|stack_|traefik)"
    echo ""
    echo "Estructura de Carpetas:"
    tree "$DEV_HOME" -L 2 2>/dev/null || find "$DEV_HOME" -maxdepth 2 -type d
    echo ""
    echo "URLs de Acceso:"
    echo "  - PHP: http://localhost:8085"
    echo "  - Python: http://localhost:8000"
    echo "  - Node.js: http://localhost:3000"
    echo "  - Nginx: http://localhost:8086"
    echo "  - MailHog: http://localhost:8025"
    echo "  - Traefik: http://localhost:8080"
    echo ""
    echo "Puertos de Debugging:"
    echo "  - PHP (Xdebug): 9003"
    echo "  - Python (debugpy): 5678"
    echo "  - Node.js (Inspector): 9229"
}

# Función principal
main() {
    case "$1" in
        "create")
            if [ -z "$2" ] || [ -z "$3" ]; then
                error "Uso: ./project-manager.sh create [tipo] [nombre]"
                exit 1
            fi
            check_docker_status
            case "$2" in
                "php")
                    create_php_project "$3"
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
                    create_react_project "$4" "$5"
                    ;;
                "vue")
                    create_vue_project "$4" "$5"
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
        "delete")
            if [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
                error "Uso: ./project-manager.sh delete [tipo] [categoría] [nombre]"
                exit 1
            fi
            delete_project "$2" "$3" "$4"
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