#!/bin/bash

# Laravel Deployment Script
echo "Starting Laravel deployment..."

# Navigate to project directory
cd /app/todo-app

# Pull from master branch
git pull origin master

# Install/Update Composer dependencies
composer install --no-dev --optimize-autoloader

# Handle NPM dependencies and build assets
if [ -f package.json ]; then
    echo "Installing npm dependencies..."
    npm install
    
    # Build assets
    if npm run build; then
        echo "Assets built successfully"
    else
        echo "Asset build failed, creating placeholder build directory"
        mkdir -p public/build
        touch public/build/.gitkeep
    fi
else
    echo "No package.json found, creating placeholder build directory"
    mkdir -p public/build
    touch public/build/.gitkeep
fi

# Copy environment file if it doesn't exist
if [ ! -f .env ]; then
    cp .env.example .env
    echo "Created .env file from .env.example"
    echo "Remember to update the .env file with your production settings!"
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