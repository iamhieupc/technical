# Install Jenkins by Helm
https://www.digitalocean.com/community/tutorials/how-to-install-jenkins-on-kubernetes

# When install jenkins, should install it on VM, link at below
https://www.digitalocean.com/community/tutorials/how-to-install-jenkins-on-ubuntu-20-04

# Jenkins master slave architect
## Jenkins Master is responsible for the following tasks:
    - Chuyển việc thực thi các job sang các node slave
    - Tổ chức build project
    - Theo dõi tất cả các node slave 
    - Có thể run các job khi cần thiết

## Jenkins Slave is responsible for the following tasks
    - Chạy các job được build
    - Responds đến demand của master

## Steps:
1. Install Java on master node
2. Install Jenkins on master node
3. Install java on slave node
4. Create a user and ssh keys on slave node
5. Copy keys on master node
6. Join slave node to master
7. Test the setup

# Pipeline basic

pipeline {
    agent any
    stages {
        stage ("stage1") {
            steps {
                echo "hello world"
            }
        }
    }
}

pipeline {
    agent any
    environment {
		DOCKERHUB_CREDENTIALS=credentials('docker_authen')
	}

    stages {
        stage('Clone git') {
            steps {
                git 'https://gitlab.com/chihieusky/test-jenkins.git'
            }
        }
        stage('Build') {
            steps {
                sh 'docker build -t test-node:latest .'
                sh 'docker tag test-node:latest hustchihieu/test-node:latest'
                // sh 'docker push hustchihieu/test-node:latest'
            }
        }

        stage('Login docker') {
            steps {
				sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
			}
        }

        stage('Push') {

			steps {
				sh 'docker push hustchihieu/test-node:latest'
			}
		}
    }
}

