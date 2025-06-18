#!/bin/bash
set -e

echo "Starting CybrScan Docker container..."

# Wait for database to be ready (if using external DB)
# sleep 5

# Initialize database if needed
if [ ! -f "/app/database/cybrscan.db" ]; then
    echo "Initializing database..."
    python init_db.py
fi

# Run database migrations if needed
# python manage.py migrate

# Create admin user if specified
if [ -n "$ADMIN_EMAIL" ] && [ -n "$ADMIN_PASSWORD" ]; then
    echo "Creating admin user..."
    python -c "
from app import app
from models import db, User
with app.app_context():
    if not User.query.filter_by(email='$ADMIN_EMAIL').first():
        admin = User(
            email='$ADMIN_EMAIL',
            username='admin',
            is_admin=True,
            is_active=True
        )
        admin.set_password('$ADMIN_PASSWORD')
        db.session.add(admin)
        db.session.commit()
        print('Admin user created')
    else:
        print('Admin user already exists')
" || echo "Failed to create admin user"
fi

# Execute the main command
exec "$@"