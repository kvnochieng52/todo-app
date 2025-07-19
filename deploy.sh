#!/bin/bash

# Laravel Deployment Script
echo "Starting Laravel deployment..."

# Navigate to project directory
cd /app/todo-app

# Since files are already copied via rsync, no need to git pull again
echo "Files already synced from Jenkins workspace"

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

# Install/Update Composer dependencies (in case of production-only dependencies)
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

# Run database migrations
echo "Running database migrations..."
php artisan migrate --force

# Clear application cache
php artisan cache:clear

# Create storage link if it doesn't exist
if [ ! -L public/storage ]; then
    php artisan storage:link
    echo "Storage link created"
fi

# Set proper permissions (using sudo)
echo "Setting permissions..."
sudo chown -R www-data:www-data /app/todo-app
sudo chmod -R 755 /app/todo-app

# Set specific permissions for writable directories
sudo chmod -R 775 /app/todo-app/storage
sudo chmod -R 775 /app/todo-app/bootstrap/cache

# Ensure log files are writable
sudo touch /app/todo-app/storage/logs/laravel.log
sudo chmod 664 /app/todo-app/storage/logs/laravel.log
sudo chown www-data:www-data /app/todo-app/storage/logs/laravel.log

# Restart services if needed (uncomment as needed)
# sudo systemctl reload nginx
# sudo systemctl restart php8.1-fpm  # Adjust PHP version as needed

echo "Deployment completed successfully!"
echo "Application is now live at your domain!"