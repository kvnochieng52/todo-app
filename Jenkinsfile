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
                        if [ ! -f package-lock.json ]; then
                            npm install --production
                        else
                            npm ci --omit=dev
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
                        if npm run build; then
                            echo "Assets built successfully"
                        elif npm run dev; then
                            echo "Assets built with dev command"
                        else
                            echo "Asset build failed, continuing..."
                        fi
                    else
                        echo "No package.json found, skipping asset build"
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
                    if [ -f phpunit.xml ] || [ -f phpunit.xml.dist ]; then
                        php artisan test
                    else
                        echo "No phpunit.xml found, skipping tests"
                    fi
                '''
            }
        }
        
        stage('Deploy') {
            steps {
                echo 'Deploying to production...'
                sh '''
                    # Copy files to deployment directory
                    rsync -av --exclude='.git' --exclude='node_modules' --exclude='.env.testing' . ${PROJECT_PATH}/
                    
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