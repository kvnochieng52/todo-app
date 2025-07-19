#!/bin/bash

# Laravel Deployment Script
echo "Starting Laravel deployment..."

# Navigate to project directory
cd /app/todo-app

# Pull latest changes
git pull origin main

# Install/Update Composer dependencies
composer install --no-dev --optimize-autoloader

# Install/Update NPM dependencies
npm ci --production

# Build assets
npm run build

# Copy environment file if it doesn't exist
if [ ! -f .env ]; then
    cp .env.example .env
    echo "Created .env file from .env.example"
fi

# Generate application key if not set
php artisan key:generate --force

# Clear and cache configuration
php artisan config:clear
php artisan config:cache

# Clear and cache routes
php artisan route:clear
php artisan route:cache

# Clear and cache views
php artisan view:clear
php artisan view:cache

# Run database migrations
php artisan migrate --force

# Clear application cache
php artisan cache:clear

# Restart queue workers (if using queues)
# php artisan queue:restart

# Set proper permissions
chown -R www-data:www-data /app/todo-app
chmod -R 755 /app/todo-app
chmod -R 775 /app/todo-app/storage
chmod -R 775 /app/todo-app/bootstrap/cache

echo "Deployment completed successfully!"