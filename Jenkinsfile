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
                git branch: 'main', url: "${GIT_REPO}"
            }
        }
        
        stage('Install Dependencies') {
            steps {
                echo 'Installing PHP dependencies...'
                sh 'composer install --no-dev --optimize-autoloader'
                
                echo 'Installing Node.js dependencies...'
                sh 'npm ci --production'
            }
        }
        
        stage('Build Assets') {
            steps {
                echo 'Building frontend assets...'
                sh 'npm run build'
            }
        }
        
        stage('Run Tests') {
            steps {
                echo 'Running Laravel tests...'
                sh 'cp .env.example .env.testing'
                sh 'php artisan key:generate --env=testing'
                sh 'php artisan test'
            }
        }
        
        stage('Deploy') {
            steps {
                echo 'Deploying to production...'
                sh '''
                    # Copy files to deployment directory
                    rsync -av --exclude='.git' --exclude='node_modules' --exclude='.env.testing' . ${PROJECT_PATH}/
                    
                    # Run deployment script
                    chmod +x ${PROJECT_PATH}/deploy.sh
                    ${PROJECT_PATH}/deploy.sh
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