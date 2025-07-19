#!/bin/bash

# Laravel Deployment Script with Updated Password
echo "Starting Laravel deployment..."

# Configuration - UPDATE THESE VALUES
JENKINS_USER_PASSWORD="j@sthomes!@4"  # Replace with actual password
DEPLOY_PATH="/app/todo-app"
SOURCE_PATH="/var/lib/jenkins/deployments/todo-app"

# Function to run sudo commands with password
run_sudo() {
    echo "$JENKINS_USER_PASSWORD" | sudo -S "$@" 2>/dev/null
}

# Verify sudo access first
echo "Verifying sudo access..."
if ! run_sudo whoami > /dev/null; then
    echo "ERROR: Cannot execute sudo commands. Please check password and sudo permissions."
    exit 1
fi
echo "Sudo access verified."

# Create the target application directory
echo "Creating application directory..."
run_sudo mkdir -p "$DEPLOY_PATH"

# Copy files from Jenkins deployment directory to final location
echo "Copying application files..."
run_sudo rsync -av --delete \
    --exclude='.git' \
    --exclude='node_modules' \
    --exclude='.env.testing' \
    --exclude='tests/' \
    --exclude='.phpunit.result.cache' \
    "$SOURCE_PATH/" "$DEPLOY_PATH/"

# Verify copy was successful
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to copy files to deployment directory"
    exit 1
fi

# Change to application directory
cd "$DEPLOY_PATH" || exit 1

# Copy environment file if it doesn't exist
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        run_sudo cp .env.example .env
        echo "Created .env file from .env.example"
        echo "Remember to update the .env file with your production settings!"
    else
        echo "Warning: No .env.example found!"
    fi
fi

# Set ownership to Jenkins user temporarily for artisan commands
echo "Setting temporary permissions for deployment..."
run_sudo chown -R jenkins:jenkins "$DEPLOY_PATH"

# Generate application key if not set
echo "Generating application key..."
php artisan key:generate --force

# Install/Update Composer dependencies
echo "Installing production dependencies..."
composer install --no-dev --optimize-autoloader --no-interaction

# Clear and cache configuration
echo "Caching configuration..."
php artisan config:clear
php artisan config:cache

# Clear and cache routes
echo "Caching routes..."
php artisan route:clear
php artisan route:cache

# Clear and cache views
echo "Caching views..."
php artisan view:clear
php artisan view:cache

# Run database migrations
echo "Running database migrations..."
php artisan migrate --force

# Clear application cache
echo "Clearing application cache..."
php artisan cache:clear

# Create storage link if it doesn't exist
if [ ! -L public/storage ]; then
    php artisan storage:link
    echo "Storage link created"
fi

# Set proper permissions for production
echo "Setting production permissions..."
run_sudo chown -R www-data:www-data "$DEPLOY_PATH"
run_sudo chmod -R 755 "$DEPLOY_PATH"

# Set specific permissions for writable directories
echo "Setting writable directory permissions..."
run_sudo chmod -R 775 "$DEPLOY_PATH/storage"
run_sudo chmod -R 775 "$DEPLOY_PATH/bootstrap/cache"

# Ensure log files are writable
echo "Setting log file permissions..."
run_sudo touch "$DEPLOY_PATH/storage/logs/laravel.log"
run_sudo chmod 664 "$DEPLOY_PATH/storage/logs/laravel.log"
run_sudo chown www-data:www-data "$DEPLOY_PATH/storage/logs/laravel.log"

# Set correct ownership for .env file
if [ -f .env ]; then
    run_sudo chown www-data:www-data "$DEPLOY_PATH/.env"
    run_sudo chmod 644 "$DEPLOY_PATH/.env"
fi

# Restart web services (uncomment and adjust as needed)
echo "Restarting web services..."
# run_sudo systemctl reload nginx
# run_sudo systemctl restart php8.1-fpm  # Adjust PHP version as needed
# run_sudo systemctl restart apache2     # If using Apache

echo ""
echo "======================================"
echo "Deployment completed successfully!"
echo "======================================"
echo "Application location: $DEPLOY_PATH"
echo "Don't forget to:"
echo "1. Update .env file with production settings"
echo "2. Configure your web server to serve from $DEPLOY_PATH/public"
echo "3. Set up SSL certificates"
echo "4. Configure database connections"
echo "======================================"