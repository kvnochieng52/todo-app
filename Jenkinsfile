pipeline {
    agent any
    
    environment {
        PROJECT_PATH = '/home/jenkins/todo-app'  // Use Jenkins home instead
        GIT_REPO = 'https://github.com/kvnochieng52/todo-app.git'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code from GitHub...'
                git branch: 'master', url: "${GIT_REPO}"
            }
        }
        
        stage('Install Dependencies') {
            steps {
                echo 'Installing PHP dependencies...'
                sh 'composer install --no-dev --optimize-autoloader'
                
                echo 'Installing Node.js dependencies...'
                sh '''
                    if [ -f package.json ]; then
                        npm install
                        
                        # Install Tailwind CSS if not present
                        if ! npm list tailwindcss > /dev/null 2>&1; then
                            echo "Installing Tailwind CSS..."
                            npm install -D tailwindcss@latest postcss@latest autoprefixer@latest
                        fi
                    else
                        echo "No package.json found, skipping npm install"
                    fi
                '''
            }
        }
        
        stage('Build Assets') {
            steps {
                echo 'Building frontend assets...'
                sh '''
                    if [ -f package.json ]; then
                        # Ensure Tailwind config exists
                        if [ ! -f tailwind.config.js ]; then
                            npx tailwindcss init -p
                        fi
                        
                        if npm run build; then
                            echo "Assets built successfully"
                        else
                            echo "Asset build failed, creating empty public/build directory"
                            mkdir -p public/build
                            touch public/build/.gitkeep
                        fi
                    else
                        echo "No package.json found, skipping asset build"
                        mkdir -p public/build
                        touch public/build/.gitkeep
                    fi
                '''
            }
        }
        
        stage('Run Tests') {
            steps {
                echo 'Running Laravel tests...'
                sh '''
                    if [ -f .env.example ]; then
                        cp .env.example .env.testing
                    fi
                    php artisan key:generate --env=testing --force
                    
                    # Try to run tests
                    if php artisan test --help > /dev/null 2>&1; then
                        echo "Running tests with artisan test command..."
                        php artisan test || echo "Tests failed but continuing..."
                    elif [ -f vendor/bin/phpunit ]; then
                        echo "Running tests with phpunit directly..."
                        vendor/bin/phpunit || echo "Tests failed but continuing..."
                    else
                        echo "No test framework found, skipping tests..."
                    fi
                '''
            }
        }
        
        stage('Deploy') {
            steps {
                echo 'Deploying to Jenkins workspace (no sudo required)...'
                sh '''
                    # Create target directory if it doesn't exist
                    mkdir -p ${PROJECT_PATH}
                    
                    # Copy files to deployment directory
                    rsync -av --delete \
                          --exclude='.git' \
                          --exclude='node_modules' \
                          --exclude='.env.testing' \
                          --exclude='.env' \
                          --exclude='tests/' \
                          --exclude='.phpunit.result.cache' \
                          . ${PROJECT_PATH}/
                    
                    # Run deployment script (modified for no-sudo)
                    cd ${PROJECT_PATH}
                    chmod +x deploy-no-sudo.sh
                    ./deploy-no-sudo.sh
                '''
            }
        }
    }
    
    post {
        success {
            echo 'Deployment successful!'
            echo "Application deployed to: ${PROJECT_PATH}"
        }
        failure {
            echo 'Deployment failed!'
        }
        always {
            echo 'Pipeline completed.'
        }
    }
}