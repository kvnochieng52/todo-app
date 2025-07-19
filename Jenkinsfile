pipeline {
    agent any
    
    environment {
        PROJECT_PATH = '/app/todo-app'
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
                    
                    # Try different test commands based on Laravel version
                    if php artisan test --help > /dev/null 2>&1; then
                        echo "Running tests with artisan test command..."
                        php artisan test
                    elif [ -f vendor/bin/phpunit ]; then
                        echo "Running tests with phpunit directly..."
                        vendor/bin/phpunit
                    else
                        echo "No test framework found, skipping tests..."
                    fi
                '''
            }
        }
        
        stage('Deploy') {
            steps {
                echo 'Deploying to production...'
                sh '''
                    # Copy files to deployment directory
                    rsync -av --exclude='.git' --exclude='node_modules' --exclude='.env.testing' --exclude='.env' . ${PROJECT_PATH}/
                    
                    # Run deployment script
                    cd ${PROJECT_PATH}
                    chmod +x deploy.sh
                    ./deploy.sh
                '''
            }
        }
    }
    
    post {
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed!'
        }
        always {
            echo 'Pipeline completed.'
        }
    }
}