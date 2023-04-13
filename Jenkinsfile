pipeline {
    agent any 
    tools {
         maven 'maven'
         jdk 'java'
    }
    stages {

        stage('Stage-0 : Static Code Analysis') { 
            steps {
                sh 'mvn clean verify sonar:sonar'
            }
        }
        stage('Stage-1 : Clean') { 
            steps {
                sh 'mvn clean'
            }
        }
        stage('Stage-2 : Validate') { 
            steps {
                sh 'mvn validate'
            }
        }
        stage('Stage-3 : Compile') { 
            steps {
                sh 'mvn compile'
            }
        }
        stage('Stage-4 : Test') { 
            steps {
                sh 'mvn test'
            }
        }
        stage('Stage-5 : Verify') { 
            steps {
                sh 'mvn verify'
            }
        }
        stage('Stage-6 : Package') { 
            steps {
                sh 'mvn package'
            }
        }
        stage('Stage-7 : Install') { 
            steps {
                sh 'mvn install'
            }
        }
        stage('Stage-8 : Deploy') { 
            steps {
                sh 'mvn deploy'
            }
        }
        stage('Stage-9 : Deployment - Deploy a Artifact binary8amdevops-6.0.3-SNAPSHOT.war file to Tomcat Server') { 
            steps {
                sh 'curl -u admin:redhat@123 -T target/**.war "http://3.86.146.214:8080/manager/text/deploy?path=/devops&update=true"'
            }
        } 
        stage('Stage-10 : SmokeTest') { 
            steps {
                sh 'curl --retry-delay 10 --retry 5 "http://3.86.146.214:8080/devops"'
            }
        }

    }
}
