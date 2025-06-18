# CybrScan Docker Setup

This directory contains the complete Docker configuration for running CybrScan in containerized environments.

## Quick Start

### Development Mode

1. Copy the environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` with your configuration

3. Start the development environment:
   ```bash
   docker-compose -f docker-compose.yml -f docker-compose.dev.yml up
   ```

4. Access the application:
   - Web App: http://localhost:8000
   - MailHog (email testing): http://localhost:8025

### Production Mode

1. Configure your environment:
   ```bash
   cp .env.example .env
   # Edit .env with production values
   ```

2. Start the production stack:
   ```bash
   docker-compose up -d
   ```

3. Access via nginx:
   - HTTP: http://localhost
   - HTTPS: https://yourdomain.com (after SSL setup)

## Directory Structure

```
CybrScan_docker/
├── Dockerfile              # Production Docker image
├── Dockerfile.dev          # Development Docker image
├── docker-compose.yml      # Base compose configuration
├── docker-compose.dev.yml  # Development overrides
├── docker-entrypoint.sh    # Container startup script
├── .dockerignore          # Files to exclude from Docker context
├── .env.example           # Environment variables template
├── nginx/                 # Nginx configuration
│   ├── nginx.conf        # Main nginx config
│   └── conf.d/           # Server configurations
│       └── default.conf  # CybrScan server config
└── README_DOCKER.md      # This file
```

## Configuration

### Environment Variables

Key environment variables (see `.env.example` for full list):

- `SECRET_KEY`: Flask secret key (generate a strong one for production)
- `FLASK_ENV`: Set to `production` or `development`
- `MAIL_*`: Email server configuration
- `STRIPE_*`: Payment processing configuration
- `ADMIN_EMAIL/PASSWORD`: Initial admin account

### Volumes

The following directories are mounted as volumes:

- `./database`: SQLite database files
- `./client_databases`: Per-client database files
- `./static/uploads`: User uploaded files
- `./static/deployments`: Generated scanner deployments
- `./generated_scanners`: Scanner generation workspace
- `./configs`: Application configurations
- `./logs`: Application logs

### Ports

- `8000`: Gunicorn application server
- `80`: Nginx HTTP
- `443`: Nginx HTTPS (when configured)
- `8025`: MailHog web UI (development only)
- `1025`: MailHog SMTP (development only)

## SSL/HTTPS Setup

For production HTTPS:

1. Update nginx configuration in `nginx/conf.d/default.conf`
2. Uncomment the HTTPS server block
3. Update domain names
4. Run certbot to obtain certificates:
   ```bash
   docker-compose run --rm certbot certonly --webroot \
     --webroot-path=/var/www/certbot \
     -d yourdomain.com \
     -d www.yourdomain.com
   ```

## Database Management

### Initialize Database
```bash
docker-compose exec web python init_db.py
```

### Create Admin User
```bash
docker-compose exec web python -c "
from app import app
from models import db, User
with app.app_context():
    admin = User(email='admin@example.com', username='admin', is_admin=True)
    admin.set_password('your-password')
    db.session.add(admin)
    db.session.commit()
"
```

### Backup Database
```bash
docker-compose exec web cp database/cybrscan.db database/cybrscan.db.backup
```

## Monitoring

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f web
```

### Health Check
```bash
curl http://localhost:8000/health
```

## Troubleshooting

### Container won't start
1. Check logs: `docker-compose logs web`
2. Verify .env file exists and is configured
3. Ensure ports 8000, 80 aren't already in use

### Database errors
1. Check database file permissions
2. Ensure volume mounts are correct
3. Try reinitializing: `docker-compose exec web python init_db.py`

### Email not working
1. In development, check MailHog at http://localhost:8025
2. In production, verify MAIL_* environment variables
3. Check firewall rules for SMTP port

## Security Considerations

1. **Change default secrets**: Update `SECRET_KEY` and admin credentials
2. **Use HTTPS**: Configure SSL certificates for production
3. **Firewall**: Only expose necessary ports
4. **Updates**: Regularly update base images and dependencies
5. **Backups**: Implement regular database backups

## Development Workflow

1. Make code changes locally
2. Changes auto-reload in development mode
3. Test in development container
4. Build production image: `docker-compose build`
5. Test production build locally
6. Deploy to production server

## Deployment

### Docker Hub
```bash
docker build -t yourusername/cybrscan:latest .
docker push yourusername/cybrscan:latest
```

### Server Deployment
```bash
# On production server
docker-compose pull
docker-compose up -d
```

## Maintenance

### Update Application
```bash
git pull
docker-compose build
docker-compose up -d
```

### Clean Up
```bash
# Remove stopped containers
docker-compose down

# Remove all data (WARNING: destructive)
docker-compose down -v
```