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
                
                echo 'Skipping Node.js dependencies for now...'
            }
        }
        
        stage('Build Assets') {
            steps {
                echo 'Skipping asset build for now...'
                sh '''
                    echo "Creating placeholder build directory"
                    mkdir -p public/build
                    touch public/build/.gitkeep
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
                    # Create target directory if it doesn't exist (without sudo first)
                    if [ ! -d ${PROJECT_PATH} ]; then
                        sudo mkdir -p ${PROJECT_PATH}
                        sudo chown jenkins:jenkins ${PROJECT_PATH}
                    fi
                    
                    # Ensure Jenkins can write to the directory
                    sudo chown -R jenkins:jenkins ${PROJECT_PATH} || true
                    
                    # Copy files to deployment directory with fixed rsync options
                    rsync -rlptgoD --no-owner --no-group --delete \
                          --exclude='.git' \
                          --exclude='node_modules' \
                          --exclude='.env.testing' \
                          --exclude='.env' \
                          --exclude='tests/' \
                          --exclude='.phpunit.result.cache' \
                          . ${PROJECT_PATH}/
                    
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