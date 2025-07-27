# Flujo de Trabajo Diario
**Autor:** nunezlagos

## Inicio de Sesión de Trabajo

Cuando inicies tu sesión de trabajo (después de encender WSL o reiniciar), sigue estos pasos:

### 1. Verificar Estado de Docker
```bash
# Verificar si Docker está corriendo
docker ps

# Si no está corriendo, iniciar Docker
sudo service docker start  # En WSL
```

### 2. Levantar el Entorno de Desarrollo
```bash
# Opción 1: Comando simple (recomendado)
docker-compose up -d

# Opción 2: Usando script
./scripts/up.sh

# Opción 3: Solo servicios específicos
docker-compose -f config/stack-compose.yml up -d
```

### 3. Verificar que los Servicios Estén Corriendo
```bash
# Ver estado de todos los servicios
docker-compose ps

# Ver logs si hay problemas
docker-compose logs -f
```

## Trabajando con Proyectos Específicos

### Para Proyectos PHP
```bash
# Los servicios ya están corriendo, solo navega a:
# http://php.localhost

# Acceder al contenedor si necesitas instalar dependencias
docker-compose exec php bash
cd /var/www/html/tu-proyecto
composer install
```

### Para Proyectos Python
```bash
# Navegar a: http://python.localhost

# Acceder al contenedor
docker-compose exec python bash
cd /app/tu-proyecto
pip install -r requirements.txt
python app.py
```

### Para Proyectos Node.js
```bash
# Navegar a: http://node.localhost

# Acceder al contenedor
docker-compose exec nodejs bash
cd /app/tu-proyecto
npm install
npm start
```

## Configuración de Email (MailHog)

Para proyectos que envían emails:

```bash
# Configuración SMTP en tu aplicación:
SMTP_HOST=localhost
SMTP_PORT=1025
SMTP_USER=  # vacío
SMTP_PASS=  # vacío

# Ver emails enviados en:
# http://mail.localhost
```

## Gestión de Servicios Durante el Trabajo

### Reiniciar un Servicio Específico
```bash
# Reiniciar PHP
docker-compose restart php

# Reiniciar Python
docker-compose restart python

# Reiniciar Node.js
docker-compose restart nodejs
```

### Ver Logs de un Servicio
```bash
# Logs de PHP
docker-compose logs -f php

# Logs de Python
docker-compose logs -f python

# Logs de todos los servicios
docker-compose logs -f
```

## Final de Sesión de Trabajo

### Opción 1: Mantener Servicios Corriendo (Recomendado)
```bash
# No hacer nada - los servicios seguirán corriendo
# Ventaja: Inicio más rápido la próxima vez
```

### Opción 2: Apagar Servicios
```bash
# Detener todos los servicios
docker-compose down

# Detener y eliminar volúmenes (cuidado con las bases de datos)
docker-compose down -v
```

## Solución de Problemas Comunes

### Servicios No Responden
```bash
# Verificar estado
docker-compose ps

# Reiniciar servicios
docker-compose restart

# Ver logs para errores
docker-compose logs
```

### Puertos Ocupados
```bash
# Ver qué está usando el puerto
netstat -tulpn | grep :80

# Detener servicios conflictivos
sudo systemctl stop apache2  # Si Apache está corriendo
sudo systemctl stop nginx    # Si Nginx está corriendo
```

### Problemas de Permisos
```bash
# Cambiar propietario de archivos de proyecto
sudo chown -R $USER:$USER ./projects/

# Dar permisos de escritura
chmod -R 755 ./projects/
```

## Comandos Útiles de Gestión

### Usando el Script de Gestión
```bash
# Ver información del entorno
./scripts/project-manager.sh info

# Iniciar servicios
./scripts/project-manager.sh start

# Detener servicios
./scripts/project-manager.sh stop

# Ver estado
./scripts/project-manager.sh status

# Ver logs
./scripts/project-manager.sh logs
```

### Limpieza del Sistema
```bash
# Limpiar contenedores no utilizados
docker system prune

# Limpiar imágenes no utilizadas
docker image prune

# Ver uso de espacio
docker system df
```

## Consejos de Productividad

1. **Mantén los servicios corriendo**: Es más eficiente dejar Docker corriendo entre sesiones
2. **Usa aliases**: Crea aliases en tu `.bashrc` para comandos frecuentes
3. **Monitorea recursos**: Usa `docker stats` para ver uso de CPU/memoria
4. **Backup regular**: Respalda tus bases de datos regularmente
5. **Actualiza imágenes**: Ejecuta `docker-compose pull` periódicamente

## 🔗 Enlaces Rápidos

- **PHP**: http://php.localhost
- **Python**: http://python.localhost
- **Node.js**: http://node.localhost
- **Nginx**: http://static.localhost
- **MailHog**: http://mail.localhost
- **Adminer**: http://localhost:8081
- **Traefik**: http://localhost:8080