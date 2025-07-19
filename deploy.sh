#!/bin/bash

# Laravel Deployment Script (No Sudo Version)
echo "Starting Laravel deployment (no-sudo version)..."

# Navigate to project directory
cd /home/jenkins/todo-app

# Copy environment file if it doesn't exist
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        cp .env.example .env
        echo "Created .env file from .env.example"
        echo "Remember to update the .env file with your production settings!"
    else
        echo "Warning: No .env.example found!"
    fi
fi

# Generate application key if not set
php artisan key:generate --force

# Install/Update Composer dependencies
echo "Ensuring production dependencies are installed..."
composer install --no-dev --optimize-autoloader --no-interaction

# Clear and cache configuration
php artisan config:clear
php artisan config:cache

# Clear and cache routes
php artisan route:clear
php artisan route:cache

# Clear and cache views
php artisan view:clear
php artisan view:cache

# Run database migrations (comment out if no DB access)
echo "Running database migrations..."
php artisan migrate --force || echo "Migration failed - check database connection"

# Clear application cache
php artisan cache:clear

# Create storage link if it doesn't exist
if [ ! -L public/storage ]; then
    php artisan storage:link || echo "Could not create storage link"
fi

# Set basic permissions (no sudo)
echo "Setting basic permissions..."
chmod -R 755 .
chmod -R 775 storage bootstrap/cache 2>/dev/null || echo "Could not set some permissions"

# Create log file if it doesn't exist
touch storage/logs/laravel.log
chmod 664 storage/logs/laravel.log 2>/dev/null || true

echo "Deployment completed!"
echo "Note: This deployment runs without sudo - some permissions may need manual adjustment"
echo "Application files are in: $(pwd)"