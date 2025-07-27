# Arquitectura del Entorno de Desarrollo Docker

**Autor:** nunezlagos  
**Versión:** 2.0  
**Descripción:** Entorno de desarrollo profesional con proxy reverso Traefik

## Descripción General de la Arquitectura

### Componentes Principales

1. **Proxy Reverso Traefik**
   - Punto de entrada principal para todos los servicios
   - Gestión automática de certificados SSL
   - Descubrimiento dinámico de servicios
   - Panel: http://localhost:8080

2. **Servicios de Desarrollo**
   - PHP 8.2 + Apache: http://php.localhost
   - Python 3.11: http://python.localhost
   - Node.js 18: http://node.localhost
   - Nginx (opcional): http://static.localhost
   - MailHog: http://mailhog.localhost

3. **Servicios de Base de Datos**
   - MySQL 8.0 (Puerto 3306)
   - PostgreSQL 15 (Puerto 5432)
   - MongoDB 6.0 (Puerto 27017)
   - Redis 7.0 (Puerto 6379)

4. **Herramientas de Administración**
   - Adminer (Puerto 8081)
   - phpMyAdmin (Puerto 8082)
   - Mongo Express (Puerto 8083)
   - Redis Commander (Puerto 8084)

### Arquitectura de Red

```
Internet/Localhost
        |
    Traefik (8080)
        |
    ┌───────┼───────┐
    │       │       │
   PHP    Python  Node.js
 (Apache) (Flask) (Express)
    │       │       │
    └───────┼───────┘
            │
    Capa de Base de Datos
   (MySQL, PostgreSQL,
    MongoDB, Redis)
```

### Enrutamiento de Servicios

| Servicio | URL | Puerto Contenedor | Puerto Debug |
|----------|-----|-------------------|-------------|
| PHP | http://php.localhost | 80 | 9003 |
| Python | http://python.localhost | 8000 | 5678 |
| Node.js | http://node.localhost | 3000 | 9229 |
| Nginx | http://static.localhost | 80 | - |
| MailHog | http://mailhog.localhost | 8025 | - |

### Organización de Proyectos

```
docker-dev-env/
├── config/               # Archivos de configuración Docker
│   ├── stack-compose.yml  # Configuración de servicios principales
│   ├── traefik-compose.yml # Proxy reverso Traefik
│   └── *.conf, *.ini      # Configuraciones de servicios
├── projects/              # Proyectos de desarrollo
│   ├── php/              # Proyectos PHP
│   ├── python/           # Proyectos Python
│   ├── nodejs/           # Proyectos Node.js
│   └── static/           # Archivos estáticos para Nginx
├── scripts/              # Scripts de gestión
│   ├── up.sh            # Iniciar entorno
│   ├── setup.sh         # Configuración inicial
│   └── project-manager.sh # Gestión de proyectos
├── docs/                 # Documentación
│   └── ARCHITECTURE.md   # Documentación técnica
└── README.md             # Documentación principal
```

### Características Principales

- **SSL Automático:** Traefik maneja los certificados SSL
- **Descubrimiento de Servicios:** Enrutamiento dinámico basado en etiquetas
- **Debugging de Desarrollo:** Puertos dedicados para cada tecnología
- **Gestión de Proyectos:** Estructura de carpetas organizada
- **Servicios Opcionales:** Nginx solo inicia cuando es necesario
- **Datos Persistentes:** Todos los datos sobreviven a reinicios de contenedores

### Consideraciones de Seguridad

- Todos los servicios se ejecutan en red Docker aislada
- Acceso a base de datos restringido al entorno de desarrollo
- Puertos de debug solo accesibles localmente
- Sin credenciales de producción en la configuración

### Optimizaciones de Rendimiento

- Cache de Traefik para contenido estático
- Volúmenes persistentes para inicio más rápido de contenedores
- Imágenes Docker optimizadas
- Asignación mínima de recursos

---

**Nota:** Este entorno está diseñado solo para desarrollo local. No usar en producción sin el endurecimiento de seguridad apropiado.