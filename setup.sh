#!/bin/bash
# setup-dev.sh - Entorno de desarrollo completo validando dependencias
# Compatible con Ubuntu, Debian y Arch
# Autor: nunezlagos, sin rodeos
set -e

echo "=== setup-dev.sh ==="
echo "Propósito: Instalar y configurar entorno dev con Docker, Traefik, bases y paneles."
echo "Autor: nunezlagos"
echo "Iniciando setup..."

# 1. Detectar Distribución
echo "[1/9] Detectando distribución..."
if [ -f /etc/os-release ]; then
  . /etc/os-release
  DISTRO=$ID
else
  echo "No se pudo detectar la distribución."
  exit 1
fi
echo "Distro detectada: $DISTRO"

# 2. Instalar dependencias base
echo "[2/9] Verificando dependencias base (curl, git)..."
install_packages_debian() {
  sudo apt update
  sudo apt install -y curl git ca-certificates lsb-release
}
install_packages_arch() {
  sudo pacman -Sy --noconfirm
  sudo pacman -S --noconfirm curl git
}
if ! command -v curl >/dev/null || ! command -v git >/dev/null; then
  echo "Instalando dependencias base..."
  case $DISTRO in
    ubuntu|debian) install_packages_debian ;;
    arch) install_packages_arch ;;
    *) echo "Distro no soportada"; exit 1 ;;
  esac
else
  echo "Dependencias base ya instaladas."
fi

# 3. Instalar Docker
echo "[3/9] Verificando Docker..."
install_docker_debian() {
  curl -fsSL https://download.docker.com/linux/$DISTRO/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/$DISTRO $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt update
  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
}
install_docker_arch() {
  sudo pacman -S --noconfirm docker docker-compose
}
if ! command -v docker >/dev/null; then
  echo "Instalando Docker..."
  case $DISTRO in
    ubuntu|debian) install_docker_debian ;;
    arch) install_docker_arch ;;
    *) echo "Distro no soportada para Docker"; exit 1 ;;
  esac
else
  echo "Docker ya instalado."
fi

# 4. Habilitar Docker y agregar usuario al grupo docker
echo "[4/9] Habilitando Docker y configurando usuario..."
sudo systemctl enable --now docker
if ! groups $USER | grep -qw docker; then
  sudo usermod -aG docker $USER
  echo "Usuario agregado al grupo docker. Reinicia sesión o ejecuta: newgrp docker"
else
  echo "Usuario ya en grupo docker."
fi

# 5. Crear red docker traefik si no existe
echo "[5/9] Creando red Docker 'traefik' si no existe..."
if ! docker network ls | grep -qw traefik; then
  docker network create traefik
  echo "Red traefik creada."
else
  echo "Red traefik ya existe."
fi

# 6. Configurar firewall (solo Ubuntu/Debian)
echo "[6/9] Configurando firewall UFW si aplica..."
if [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "debian" ]]; then
  if ! command -v ufw >/dev/null; then
    echo "UFW no está instalado. Instalando..."
    sudo apt update
    sudo apt install -y ufw
  fi
  
  if ! sudo ufw status | grep -q active; then
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow ssh
    sudo ufw allow 80
    sudo ufw allow 443
    sudo ufw --force enable
    echo "UFW habilitado."
  else
    echo "UFW ya estaba habilitado."
  fi
else
  echo "Configura iptables o nftables manualmente en Arch."
fi

# 7. Crear estructura de carpetas
echo "[7/9] Creando estructura de carpetas en ~/dev/docker..."
DEV_HOME="$HOME/dev"
mkdir -p "$DEV_HOME/docker/traefik" "$DEV_HOME/docker/stack"
echo "Carpetas creadas."

# 8. Copiar docker-compose desde docker-files
echo "[8/9] Copiando archivos docker-compose..."
DOCKER_FILES_DIR="$(dirname "$0")/docker-files"
TRAEFIK_COMPOSE="$DEV_HOME/docker/traefik/docker-compose.yml"
STACK_COMPOSE="$DEV_HOME/docker/stack/docker-compose.yml"

if [ ! -f "$TRAEFIK_COMPOSE" ]; then
  cp "$DOCKER_FILES_DIR/traefik-compose.yml" "$TRAEFIK_COMPOSE"
  echo "docker-compose Traefik copiado."
else
  echo "docker-compose Traefik ya existe."
fi

if [ ! -f "$STACK_COMPOSE" ]; then
  cp "$DOCKER_FILES_DIR/stack-compose.yml" "$STACK_COMPOSE"
  echo "docker-compose stack copiado."
else
  echo "docker-compose stack ya existe."
fi

# 9. Crear script para levantar stack
echo "[9/9] Creando script para levantar stack..."
UP_SCRIPT="$DEV_HOME/docker/up.sh"
if [ ! -f "$UP_SCRIPT" ]; then
  cat > "$UP_SCRIPT" <<'EOL'
#!/bin/bash
docker compose -f ~/dev/docker/stack/docker-compose.yml up -d
EOL
  chmod +x "$UP_SCRIPT"
  echo "Script de arranque creado: $UP_SCRIPT"
else
  echo "Script de arranque ya existe."
fi

# Fin
echo -e "\nSetup completo. Para arrancar:"
echo "1) cd $DEV_HOME/docker/traefik && docker compose up -d"
echo "2) $UP_SCRIPT"
echo "Accede a paneles en localhost:8081 (MySQL), :8082 (PostgreSQL), :8083 (Mongo)"
echo "Traefik dashboard: http://localhost:8080"
echo "Reinicia sesión si agregaste usuario al grupo docker."
exit 0
