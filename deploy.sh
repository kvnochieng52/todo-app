#!/bin/bash

# Laravel Deployment Script
echo "Starting Laravel deployment..."

# Navigate to project directory
cd /app/todo-app

# Pull from master branch (not main)
git pull origin master

# Install/Update Composer dependencies
composer install --no-dev --optimize-autoloader

# Handle NPM dependencies
if [ -f package.json ]; then
    # Check if package-lock.json exists, if not create it
    if [ ! -f package-lock.json ]; then
        echo "Creating package-lock.json..."
        npm install --production
    else
        npm ci --omit=dev
    fi
    
    # Build assets
    if npm run build; then
        echo "Assets built successfully"
    elif npm run dev; then
        echo "Assets built with dev command"
    else
        echo "Asset build failed, continuing..."
    fi
else
    echo "No package.json found, skipping npm steps"
fi

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

# Set proper permissions (using sudo)
echo "Setting permissions..."
sudo chown -R www-data:www-data /app/todo-app
sudo chmod -R 755 /app/todo-app
sudo chmod -R 775 /app/todo-app/storage
sudo chmod -R 775 /app/todo-app/bootstrap/cache

echo "Deployment completed successfully!"