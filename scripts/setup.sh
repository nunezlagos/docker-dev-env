#!/bin/bash
# setup-dev.sh - Entorno de desarrollo completo con validación de dependencias
# Compatible con Ubuntu, Debian y Arch
# Autor: nunezlagos
set -euo pipefail

# Variables globales
LOG_FILE="/tmp/setup-dev.log"
ERROR_COUNT=0
MAX_RETRIES=3
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Función de logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Función de manejo de errores
handle_error() {
    local exit_code=$?
    ERROR_COUNT=$((ERROR_COUNT + 1))
    log "ERROR: $1 (código: $exit_code)"
    if [ $ERROR_COUNT -ge $MAX_RETRIES ]; then
        log "ADVERTENCIA: Máximo de errores alcanzado, continuando..."
        ERROR_COUNT=0
    fi
    return 0
}

# Función de retry
retry() {
    local retries=0
    while [ $retries -lt $MAX_RETRIES ]; do
        if "$@"; then
            return 0
        fi
        retries=$((retries + 1))
        log "Reintento $retries/$MAX_RETRIES para: $*"
        sleep 2
    done
    log "ADVERTENCIA: Falló después de $MAX_RETRIES intentos: $*"
    return 0
}

log "=== setup-dev.sh ==="
log "Propósito: Instalar y configurar entorno dev con Docker, Traefik, bases y paneles."
log "Autor: nunezlagos"
log "Iniciando setup..."
log "Log guardado en: $LOG_FILE"

# 1. Detectar Distribución
log "[1/9] Detectando distribución..."
if [ -f /etc/os-release ]; then
  . /etc/os-release
  DISTRO=$ID
  log "Distribución detectada: $DISTRO"
else
  log "ERROR: No se pudo detectar la distribución."
  log "Intentando detección manual..."
  if command -v apt >/dev/null 2>&1; then
    DISTRO="ubuntu"
    log "Sistema basado en Debian/Ubuntu detectado"
  elif command -v pacman >/dev/null 2>&1; then
    DISTRO="arch"
    log "Sistema Arch Linux detectado"
  else
    log "ADVERTENCIA: Sistema no soportado, asumiendo Ubuntu"
    DISTRO="ubuntu"
  fi
fi

# 2. Instalar dependencias base
log "[2/9] Verificando dependencias base (curl, git)..."

install_packages_debian() {
  log "Actualizando repositorios..."
  retry sudo apt update || handle_error "falló apt update"
  log "Instalando paquetes base..."
  retry sudo apt install -y curl git zip unzip ca-certificates lsb-release gnupg2 software-properties-common iproute2 || handle_error "Falló la instalación de paquetes base"
}

install_packages_arch() {
  log "Actualizando repositorios de Arch..."
  retry sudo pacman -Sy --noconfirm || handle_error "falló sincronización de pacman"
  log "Instalando paquetes base..."
  retry sudo pacman -S --noconfirm curl git zip unzip iproute2 || handle_error "Falló la instalación de paquetes base"
}

# Verificar e instalar dependencias
missing_deps=()
! command -v curl >/dev/null && missing_deps+=("curl")
! command -v git >/dev/null && missing_deps+=("git")
! command -v zip >/dev/null && missing_deps+=("zip")
! command -v unzip >/dev/null && missing_deps+=("unzip")
! command -v ss >/dev/null && missing_deps+=("iproute2")

if [ ${#missing_deps[@]} -gt 0 ]; then
  log "Dependencias faltantes: ${missing_deps[*]}"
  log "Instalando dependencias base..."
  case $DISTRO in
    ubuntu|debian) install_packages_debian ;;
    arch) install_packages_arch ;;
    *) log "ADVERTENCIA: Distribución no soportada para instalación automática" ;;
  esac
  
  # Verificar instalación
  for dep in "${missing_deps[@]}"; do
    if command -v "$dep" >/dev/null; then
      log "$dep instalado exitosamente"
    else
      log "$dep no se pudo instalar"
    fi
  done
else
  log "Dependencias base ya instaladas."
fi

# 3. Instalar Docker
log "[3/9] Verificando Docker..."

install_docker_debian() {
  log "Configurando repositorio Docker para $DISTRO..."
  
  # Remover instalaciones previas problemáticas
  retry sudo apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
  
  # Agregar clave GPG
  retry curl -fsSL https://download.docker.com/linux/$DISTRO/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg || handle_error "Error agregando clave GPG Docker"
  
  # Agregar repositorio
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/$DISTRO $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  
  # Instalar Docker
  retry sudo apt update || handle_error "Error actualizando repositorios"
  retry sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-compose || handle_error "Error instalando Docker"
}

install_docker_arch() {
  log "Instalando Docker en Arch Linux..."
  retry sudo pacman -S --noconfirm docker docker-compose || handle_error "Error instalando Docker en Arch"
}

# Verificar versión mínima de Docker
check_docker_version() {
  if ! command -v docker >/dev/null; then
    log " Docker no está disponible después de la instalación"
    return 1
  fi
  
  local version=$(docker --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
  if [ -z "$version" ]; then
    log " No se pudo obtener la versión de Docker"
    return 1
  fi
  
  local major=$(echo $version | cut -d. -f1)
  local minor=$(echo $version | cut -d. -f2)
  
  if [ "$major" -lt 20 ] || ([ "$major" -eq 20 ] && [ "$minor" -lt 10 ]); then
    log "ADVERTENCIA: Docker versión $version detectada. Se recomienda versión 20.10 o superior."
    log "Actualizando Docker automáticamente..."
    case $DISTRO in
      ubuntu|debian) install_docker_debian ;;
      arch) install_docker_arch ;;
    esac
    # Verificar nueva versión
    local new_version=$(docker --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    log "Docker actualizado a versión: $new_version"
  else
    log " Docker versión $version - Compatible."
  fi
}

# Instalar o verificar Docker
if ! command -v docker >/dev/null; then
  log "Docker no encontrado. Instalando..."
  case $DISTRO in
    ubuntu|debian) install_docker_debian ;;
    arch) install_docker_arch ;;
    *) log "ADVERTENCIA: Distro no soportada para Docker" ;;
  esac
else
  log " Docker ya instalado."
fi

# Verificar versión independientemente
check_docker_version || log "ADVERTENCIA: Problemas con la verificación de Docker"

# 4. Habilitar Docker y agregar usuario al grupo docker
log "[4/9] Habilitando Docker y configurando usuario..."

# Habilitar servicio Docker
if systemctl is-active --quiet docker; then
  log " Servicio Docker ya está activo"
else
  log "Habilitando servicio Docker..."
  retry sudo systemctl enable docker || handle_error "Error habilitando servicio Docker"
  retry sudo systemctl start docker || handle_error "Error iniciando servicio Docker"
  sleep 3
  if systemctl is-active --quiet docker; then
    log " Servicio Docker iniciado correctamente"
  else
    log " Servicio Docker no se pudo iniciar"
  fi
fi

# Agregar usuario al grupo docker
if groups $USER | grep -qw docker; then
  log " Usuario ya en grupo docker"
else
  log "Agregando usuario al grupo docker..."
  retry sudo usermod -aG docker $USER || handle_error "Error agregando usuario al grupo docker"
  log " Usuario agregado al grupo docker. Reinicia sesión o ejecuta: newgrp docker"
fi

# Verificar docker-compose
log "Verificando docker-compose..."
if command -v docker-compose >/dev/null; then
  compose_version=$(docker-compose --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
  log " docker-compose versión $compose_version ya instalado"
else
  log "docker-compose no encontrado. Instalando..."
  case $DISTRO in
    ubuntu|debian)
      retry sudo apt update || handle_error "Error actualizando repositorios"
      retry sudo apt install -y docker-compose || handle_error "Error instalando docker-compose"
      ;;
    arch)
      retry sudo pacman -S --noconfirm docker-compose || handle_error "Error instalando docker-compose"
      ;;
    *)
      log "ADVERTENCIA: Instalación manual requerida para docker-compose"
      ;;
  esac
  
  # Verificar instalación
  if command -v docker-compose >/dev/null; then
    log " docker-compose instalado correctamente"
  else
    log " docker-compose no se pudo instalar"
  fi
fi

# 5. Crear red docker traefik si no existe
log "[5/9] Creando red Docker 'traefik' si no existe..."
if docker network ls | grep -qw traefik; then
  log " Red traefik ya existe"
else
  log "Creando red traefik..."
  retry docker network create traefik || handle_error "Error creando red Docker"
  
  # Verificar creación
  if docker network ls | grep -qw traefik; then
    log " Red traefik creada correctamente"
  else
    log " Red traefik no se pudo crear"
  fi
fi

# 6. Configurar firewall (solo Ubuntu/Debian)
log "[6/9] Configurando firewall UFW si aplica..."
if [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "debian" ]]; then
  if ! command -v ufw >/dev/null; then
    log "UFW no está instalado. Instalando..."
    retry sudo apt update || handle_error "Error actualizando repositorios"
    retry sudo apt install -y ufw || handle_error "Error instalando UFW"
    
    # Verificar instalación
    if command -v ufw >/dev/null; then
      log " UFW instalado correctamente"
    else
      log " UFW no se pudo instalar"
    fi
  else
    ufw_version=$(ufw --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' | head -1)
    log " UFW versión $ufw_version ya instalado"
  fi
  
  if ! sudo ufw status | grep -q active; then
    log "Configurando reglas de firewall..."
    retry sudo ufw default deny incoming || handle_error "Error configurando política por defecto"
    retry sudo ufw default allow outgoing || handle_error "Error configurando política por defecto"
    retry sudo ufw allow ssh || handle_error "Error permitiendo SSH"
    retry sudo ufw allow 80 || handle_error "Error permitiendo puerto 80"
    retry sudo ufw allow 443 || handle_error "Error permitiendo puerto 443"
    retry sudo ufw allow 8080/tcp || handle_error "Error permitiendo puerto 8080"
    retry sudo ufw --force enable || handle_error "Error habilitando UFW"
    
    # Verificar estado
    if sudo ufw status | grep -q "Status: active"; then
      log " UFW habilitado y configurado correctamente"
    else
      log " UFW no se pudo activar"
    fi
  else
    log " UFW ya estaba habilitado"
  fi
else
  log "ADVERTENCIA: Configura iptables o nftables manualmente en Arch"
fi

# 7. Instalar versionadores de Node.js y PHP
log "[7/9] Instalando nvm (Node.js) y phpenv (PHP)..."

# Instalar nvm (Node.js Version Manager)
if ! command -v nvm >/dev/null; then
  log "Instalando nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash || handle_error "Error instalando nvm"
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  log " nvm instalado"
else
  log " nvm ya está instalado"
fi

# Instalar phpenv (PHP Version Manager)
if ! command -v phpenv >/dev/null; then
  log "Instalando phpenv..."
  git clone https://github.com/phpenv/phpenv.git ~/.phpenv || handle_error "Error clonando phpenv"
  export PHPENV_ROOT="$HOME/.phpenv"
  export PATH="$PHPENV_ROOT/bin:$PATH"
  if ! grep -q 'phpenv init' ~/.bashrc; then
    echo 'export PHPENV_ROOT="$HOME/.phpenv"' >> ~/.bashrc
    echo 'export PATH="$PHPENV_ROOT/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(phpenv init -)"' >> ~/.bashrc
  fi
  eval "$(phpenv init -)"
  log " phpenv instalado"
else
  log " phpenv ya está instalado"
fi

# 8. Crear estructura de carpetas
log "[8/10] Creando estructura de carpetas en ~/dev/docker..."
DEV_HOME="$HOME/dev"
# Estructura minimalista
mkdir -p "$DEV_HOME/docker"/{services,projects,html}

# Crear archivos de ejemplo
echo "<?php echo '<h1>Proyectos PHP</h1>'; ?>" > "$DEV_HOME/docker/projects/index.php"
echo "console.log('Proyectos Node.js');" > "$DEV_HOME/docker/projects/README.txt"
echo "print('Proyectos Python')" > "$DEV_HOME/docker/projects/main.py"
echo "<!DOCTYPE html><html><head><title>Static Files</title></head><body><h1>¡Archivos estáticos!</h1></body></html>" > "$DEV_HOME/docker/html/index.html"

log " Carpetas y archivos de ejemplo creados."

# 8. Configurar archivos de entorno
log "[8/9] Configurando archivos de entorno..."

# Crear .env si no existe
if [ -f "$DEV_HOME/docker/.env" ]; then
  log " Archivo .env ya existe"
else
  log "Creando archivo .env..."
  cat > "$DEV_HOME/docker/.env" << 'EOF'
# Configuración del entorno
COMPOSE_PROJECT_NAME=devenv
TRAEFIK_DOMAIN=localhost
TRAEFIK_API_DASHBOARD=true
TRAEFIK_LOG_LEVEL=INFO

# Base de datos
MYSQL_ROOT_PASSWORD=rootpassword
MYSQL_DATABASE=devdb
MYSQL_USER=devuser
MYSQL_PASSWORD=devpassword

# Redis
REDIS_PASSWORD=redispassword

# Configuración de red
DOCKER_NETWORK=traefik-network
EOF
  
  if [ -f "$DEV_HOME/docker/.env" ]; then
    log " Archivo .env creado correctamente"
  else
    handle_error "Error creando archivo .env"
  fi
fi

# 9. Copiar archivos de configuración y scripts
log "[9/10] Copiando archivos de configuración y scripts..."

# Copiar scripts a la carpeta de desarrollo
cp "$SCRIPT_DIR/up.sh" "$DEV_HOME/docker/up.sh"
cp "$SCRIPT_DIR/project-manager.sh" "$DEV_HOME/docker/project-manager.sh"
chmod +x "$DEV_HOME/docker/up.sh"
chmod +x "$DEV_HOME/docker/project-manager.sh"
log "✓ Scripts copiados correctamente"

# Copiar archivos de configuración
CONFIG_SRC_DIR="$SCRIPT_DIR/../config"
if [ -d "$CONFIG_SRC_DIR" ]; then
  cp -r "$CONFIG_SRC_DIR" "$DEV_HOME/docker/config"
  log "✓ Archivos de configuración copiados correctamente"
else
  log "ADVERTENCIA: No se encontró la carpeta config en $CONFIG_SRC_DIR"
fi

# Copiar carpeta examples al entorno docker
EXAMPLES_SRC_DIR="$SCRIPT_DIR/../examples"
EXAMPLES_DST_DIR="$DEV_HOME/docker/examples"
if [ -d "$EXAMPLES_SRC_DIR" ]; then
  if [ ! -d "$EXAMPLES_DST_DIR" ]; then
    cp -r "$EXAMPLES_SRC_DIR" "$EXAMPLES_DST_DIR"
    log "✓ Carpeta examples copiada correctamente"
  else
    log "✓ Carpeta examples ya existe en el entorno docker"
  fi
else
  log "ADVERTENCIA: No se encontró la carpeta examples en $EXAMPLES_SRC_DIR"
fi

# Cambiar a la carpeta principal de desarrollo Docker
cd "$DEV_HOME/docker"

# 10. Copiar docker-compose desde docker-files
log "[10/11] Copiando archivos docker-compose..."
DOCKER_FILES_DIR="$(dirname "$0")/docker-files"
TRAEFIK_COMPOSE="$DEV_HOME/docker/traefik/docker-compose.yml"
STACK_COMPOSE="$DEV_HOME/docker/stack/docker-compose.yml"

# Copiar Traefik compose
if [ -f "$DOCKER_FILES_DIR/traefik-compose.yml" ]; then
  if [ ! -f "$TRAEFIK_COMPOSE" ]; then
    if cp "$DOCKER_FILES_DIR/traefik-compose.yml" "$TRAEFIK_COMPOSE" 2>/dev/null; then
      log " Traefik compose copiado correctamente"
    else
      handle_error "Error copiando Traefik compose"
    fi
  else
    log " docker-compose Traefik ya existe"
  fi
else
  log "ADVERTENCIA: No se encontró traefik-compose.yml en $DOCKER_FILES_DIR/"
fi

# Copiar Stack compose
if [ -f "$DOCKER_FILES_DIR/stack-compose.yml" ]; then
  if [ ! -f "$STACK_COMPOSE" ]; then
    if cp "$DOCKER_FILES_DIR/stack-compose.yml" "$STACK_COMPOSE" 2>/dev/null; then
      log " Stack compose copiado correctamente"
    else
      handle_error "Error copiando Stack compose"
    fi
  else
    log " docker-compose stack ya existe"
  fi
else
  log "ADVERTENCIA: No se encontró stack-compose.yml en $DOCKER_FILES_DIR/"
fi



# Copiar php.ini
if [ -f "$DOCKER_FILES_DIR/php.ini" ]; then
  if [ ! -f "$DEV_HOME/docker/stack/php.ini" ]; then
    if cp "$DOCKER_FILES_DIR/php.ini" "$DEV_HOME/docker/stack/php.ini" 2>/dev/null; then
      log " php.ini copiado correctamente"
    else
      handle_error "Error copiando php.ini"
    fi
  else
    log " php.ini ya existe"
  fi
else
  log "ADVERTENCIA: No se encontró php.ini en $DOCKER_FILES_DIR/"
fi

# 10. Crear script para levantar stack
log "[10/10] Creando script para levantar stack..."
UP_SCRIPT="$DEV_HOME/docker/up.sh"
if [ -f "$UP_SCRIPT" ]; then
  log " Script up.sh ya existe"
else
  log "Creando script up.sh..."
  cat > "$UP_SCRIPT" << 'EOF'
#!/bin/bash
set -e
cd "$(dirname "$0")"
echo "Levantando Traefik..."
cd traefik && docker-compose up -d
echo "Levantando Stack..."
cd ../stack && docker-compose up -d
echo "Stack levantado. Accede a http://localhost:8080 para Traefik dashboard"
EOF
  
  if chmod +x "$UP_SCRIPT" 2>/dev/null; then
    log " Script up.sh creado y permisos asignados"
  else
    handle_error "Error creando script up.sh"
  fi
fi

# Copiar y hacer ejecutable el gestor de proyectos
SCRIPT_DIR="$(dirname "$0")"
if [ -f "$SCRIPT_DIR/project-manager.sh" ]; then
  if [ ! -f "$DEV_HOME/docker/project-manager.sh" ]; then
    if cp "$SCRIPT_DIR/project-manager.sh" "$DEV_HOME/docker/project-manager.sh" 2>/dev/null; then
      if chmod +x "$DEV_HOME/docker/project-manager.sh" 2>/dev/null; then
        log " Gestor de proyectos copiado y configurado como ejecutable"
      else
        handle_error "Error asignando permisos al gestor de proyectos"
      fi
    else
      handle_error "Error copiando gestor de proyectos"
    fi
  else
    log " Gestor de proyectos ya existe"
  fi
else
  log "ADVERTENCIA: No se encontró project-manager.sh en $SCRIPT_DIR/"
fi
 
cd ~/dev/docker
# Resumen final
log ""
log "=== INSTALACIÓN COMPLETADA ==="
log "Errores encontrados: $ERROR_COUNT"
log "Carpeta de desarrollo: $DEV_HOME/docker"
log "Para levantar el stack: cd $DEV_HOME/docker && ./up.sh"
log "Dashboard Traefik: http://localhost:8080"
log ""
log "IMPORTANTE: Si agregaste el usuario al grupo docker, reinicia sesión o ejecuta:"
log "newgrp docker"
log ""
log "Para verificar que Docker funciona:"
log "docker --version"
log "docker-compose --version"
log "docker ps"
log ""
log "Si usas Docker Compose v2, puedes usar 'docker compose' en lugar de 'docker-compose'"
log "Para verificar: docker compose version"

# Verificaciones finales
log ""
log "=== VERIFICACIONES FINALES ==="
if command -v docker >/dev/null; then
  log " Docker instalado: $(docker --version)"
else
  log " Docker no encontrado"
fi

if command -v docker-compose >/dev/null; then
  log " Docker Compose instalado: $(docker-compose --version)"
else
  log " Docker Compose no encontrado"
fi

if systemctl is-active --quiet docker 2>/dev/null; then
  log " Servicio Docker activo"
else
  log " Servicio Docker no activo"
fi

if groups $USER | grep -qw docker; then
  log " Usuario en grupo docker"
else
  log " Usuario no en grupo docker"
fi

if docker network ls 2>/dev/null | grep -q traefik; then
  log " Red Docker traefik creada"
else
  log " Red Docker traefik no encontrada"
fi

if [ $ERROR_COUNT -eq 0 ]; then
  log ""
  log " INSTALACIÓN EXITOSA - Sin errores detectados"
else
  log ""
  log "⚠ INSTALACIÓN COMPLETADA CON $ERROR_COUNT ERRORES"
  log "Revisa los mensajes anteriores para más detalles"
fi
exit 0
