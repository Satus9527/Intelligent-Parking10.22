// Jenkinsfile (存放在项目根目录)
pipeline {
  agent any
  
  environment {
    // 环境变量配置（必须通过TREA安全管理注入）
    DB_HOST = credentials('db-host')
    DB_USER = credentials('db-user')
    DB_PASS = credentials('db-pass')
  }
  
  stages {
    stage('Build') {
      steps {
        sh 'mvn clean package -DskipTests'
      }
      post {
        success {
          archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
        }
      }
    }
    
    stage('Unit Test') {
      steps {
        sh 'mvn test'
      }
      post {
        always {
          junit '**/target/surefire-reports/TEST-*.xml'
        }
      }
    }
    
    stage('Code Quality') {
      steps {
        sh 'mvn checkstyle:check'
        sh 'mvn sonar:sonar'
      }
    }
    
    stage('Security Scan') {
      steps {
        sh 'mvn dependency-check:check'
      }
    }
  }
  
  post {
    failure {
      slackSend channel: '#parking-dev-alerts', message: "CI Failed: Job '${env.JOB_NAME}' (${env.BUILD_NUMBER})"
    }
  }
}