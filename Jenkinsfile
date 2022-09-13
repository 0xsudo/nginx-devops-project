pipeline {
    agent any
    parameters {
        choice(
            name: 'Action',
            choices: "apply\ndestroy",
            description: 'Create or destroy the instance'
        )
    }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', credentialsId: 'jenkins', url: 'git@github.com:0xsudo/nginx-devops-project.git'
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build nginx/ -t kaokakelvin/nginx-image:""$BUILD_ID"" --no-cache'
            }
        }

        stage('Docker Publish') {
            steps {
                withDockerRegistry([credentialsId: "kaokakelvin-dockerhub", url: "https://hub.docker.com/u/kaokakelvin"]) {
                    sh 'docker push kaokakelvin/nginx-image:""$BUILD_ID""'
                }
            }
        }

        stage('Terraform') {
            steps {
                script {
                    if (params.Action == "apply") {
                        sh 'terraform -chdir=./terraform/static-web init'
                        sh 'terraform -chdir=./terraform/static-web apply --auto-approve'
                    }
                    else {
                        sh 'terraform -chdir=./terraform/static-web destroy --auto-approve'
                    }
                }
            }
        }

        stage('Ansible'){
            steps {
                retry(count: 10) {
                    ansiblePlaybook(
                        installation: 'ansible',
                        playbook: 'ansible/static-web/ec2-site-playbook.yaml',
                        inventory: '/etc/ansible/hosts/aws_ec2.yaml',
                        credentialsId: 'AKIAZIH24AZPACRJM7WT'
                    )
                }
            }
        }
    }
    
    post {
        always {
            sh 'docker logout'
        }
    }

}