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

        stage('Terraform') {
            steps {
                script {
                    if (params.Action == "apply") {
                        sh 'terraform -chdir=./terraform/static-web init'
                        sh 'terraform -chdir=./terraform/static-web --auto-approve apply'
                    }
                    else {
                        sh 'terraform -chdir=./terraform/static-web --auto-approve destroy'
                    }
                }
            }
        }

        stage('Ansible'){
            steps{
                retry(count: 10) {
                    sh 'ansible-playbook -i ansible/aws_ec2.yaml ansible/static-web/site.yaml'
                }
            }
        }
    }

}