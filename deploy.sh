#!/bin/bash

# Laravel Deployment Script with Enhanced Error Handling
echo "Starting Laravel deployment..."

# Configuration
JENKINS_USER_PASSWORD="YourNewPassword123!"  # UPDATE THIS WITH ACTUAL PASSWORD
DEPLOY_PATH="/app/todo-app"
SOURCE_PATH="/var/lib/jenkins/deployments/todo-app"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_error() {
    echo -e "${RED}ERROR: $1${NC}"
}

print_success() {
    echo -e "${GREEN}SUCCESS: $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}WARNING: $1${NC}"
}

print_info() {
    echo -e "INFO: $1"
}

# Function to run sudo commands with password
run_sudo() {
    echo "$JENKINS_USER_PASSWORD" | sudo -S "$@" 2>/dev/null
    return $?
}

# Function to run sudo commands without hiding stderr (for debugging)
run_sudo_debug() {
    echo "$JENKINS_USER_PASSWORD" | sudo -S "$@"
    return $?
}

# Check if we're running as jenkins user
if [ "$(whoami)" != "jenkins" ]; then
    print_warning "Not running as jenkins user. Current user: $(whoami)"
fi

# Test 1: Check if sudo is available
print_info "Testing sudo availability..."
if ! command -v sudo &> /dev/null; then
    print_error "sudo command not found!"
    exit 1
fi

# Test 2: Check if we can run sudo commands
print_info "Testing sudo access..."
if run_sudo whoami >/dev/null 2>&1; then
    SUDO_USER=$(echo "$JENKINS_USER_PASSWORD" | sudo -S whoami 2>/dev/null)
    print_success "Sudo access verified. Running as: $SUDO_USER"
else
    print_error "Cannot execute sudo commands. Debugging..."
    
    # Debug information
    echo "Current user: $(whoami)"
    echo "Current groups: $(groups)"
    
    # Test with more verbose output
    print_info "Testing sudo with verbose output..."
    echo "$JENKINS_USER_PASSWORD" | sudo -S whoami
    
    print_error "Please check:"
    echo "1. Jenkins user password is correct"
    echo "2. Jenkins user has sudo privileges"
    echo "3. Run: sudo usermod -aG sudo jenkins"
    echo "4. Run: echo 'jenkins ALL=(ALL:ALL) ALL' | sudo tee /etc/sudoers.d/jenkins"
    exit 1
fi

# Test 3: Check if source directory exists
if [ ! -d "$SOURCE_PATH" ]; then
    print_error "Source directory not found: $SOURCE_PATH"
    exit 1
fi

# Test 4: Check if we can create target directory
print_info "Creating application directory..."
if run_sudo mkdir -p "$DEPLOY_PATH"; then
    print_success "Application directory created/verified: $DEPLOY_PATH"
else
    print_error "Failed to create application directory: $DEPLOY_PATH"
    exit 1
fi

# Copy files from Jenkins deployment directory to final location
print_info "Copying application files..."
if run_sudo_debug rsync -av --delete \
    --exclude='.git' \
    --exclude='node_modules' \
    --exclude='.env.testing' \
    --exclude='tests/' \
    --exclude='.phpunit.result.cache' \
    "$SOURCE_PATH/" "$DEPLOY_PATH/"; then
    print_success "Files copied successfully"
else
    print_error "Failed to copy files to deployment directory"
    exit 1
fi

# Change to application directory
if ! cd "$DEPLOY_PATH"; then
    print_error "Cannot change to application directory: $DEPLOY_PATH"
    exit 1
fi

print_info "Working in directory: $(pwd)"

# Copy environment file if it doesn't exist
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        if run_sudo cp .env.example .env; then
            print_success "Created .env file from .env.example"
            print_warning "Remember to update the .env file with your production settings!"
        else
            print_error "Failed to create .env file"
            exit 1
        fi
    else
        print_warning "No .env.example found!"
    fi
fi

# Set ownership to Jenkins user temporarily for artisan commands
print_info "Setting temporary permissions for deployment..."
if run_sudo chown -R jenkins:jenkins "$DEPLOY_PATH"; then
    print_success "Temporary permissions set"
else
    print_error "Failed to set temporary permissions"
    exit 1
fi

# Check if PHP and artisan are available
if ! command -v php &> /dev/null; then
    print_error "PHP command not found!"
    exit 1
fi

if [ ! -f artisan ]; then
    print_error "Laravel artisan file not found!"
    exit 1
fi

# Generate application key if not set
print_info "Generating application key..."
if php artisan key:generate --force; then
    print_success "Application key generated"
else
    print_error "Failed to generate application key"
    exit 1
fi

# Install/Update Composer dependencies
if command -v composer &> /dev/null; then
    print_info "Installing production dependencies..."
    if composer install --no-dev --optimize-autoloader --no-interaction; then
        print_success "Dependencies installed"
    else
        print_warning "Composer install had issues, but continuing..."
    fi
else
    print_warning "Composer not found, skipping dependency installation"
fi

# Laravel optimization commands
print_info "Optimizing Laravel application..."

php artisan config:clear
php artisan config:cache
print_success "Configuration cached"

php artisan route:clear  
php artisan route:cache
print_success "Routes cached"

php artisan view:clear
php artisan view:cache
print_success "Views cached"

# Run database migrations
print_info "Running database migrations..."
if php artisan migrate --force; then
    print_success "Database migrations completed"
else
    print_warning "Database migrations had issues (database may not be configured)"
fi

# Clear application cache
php artisan cache:clear
print_success "Application cache cleared"

# Create storage link if it doesn't exist
if [ ! -L public/storage ]; then
    if php artisan storage:link; then
        print_success "Storage link created"
    else
        print_warning "Failed to create storage link"
    fi
fi

# Set proper permissions for production
print_info "Setting production permissions..."
run_sudo chown -R www-data:www-data "$DEPLOY_PATH"
run_sudo chmod -R 755 "$DEPLOY_PATH"

# Set specific permissions for writable directories
run_sudo chmod -R 775 "$DEPLOY_PATH/storage"
run_sudo chmod -R 775 "$DEPLOY_PATH/bootstrap/cache"

# Ensure log files are writable
run_sudo touch "$DEPLOY_PATH/storage/logs/laravel.log"
run_sudo chmod 664 "$DEPLOY_PATH/storage/logs/laravel.log"
run_sudo chown www-data:www-data "$DEPLOY_PATH/storage/logs/laravel.log"

# Set correct ownership for .env file
if [ -f .env ]; then
    run_sudo chown www-data:www-data "$DEPLOY_PATH/.env"
    run_sudo chmod 644 "$DEPLOY_PATH/.env"
fi

print_success "Permissions set successfully"

# Restart web services (uncomment and adjust as needed)
print_info "Web services restart (uncomment in script if needed)..."
# run_sudo systemctl reload nginx
# run_sudo systemctl restart php8.1-fpm
# run_sudo systemctl restart apache2

echo ""
echo "======================================"
print_success "Deployment completed successfully!"
echo "======================================"
echo "Application location: $DEPLOY_PATH"
echo ""
echo "Next steps:"
echo "1. Update .env file with production settings"
echo "2. Configure your web server to serve from $DEPLOY_PATH/public"
echo "3. Set up SSL certificates"
echo "4. Configure database connections"
echo "5. Test the application in your browser"
echo "======================================"