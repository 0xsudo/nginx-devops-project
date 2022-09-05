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
                        sh 'terraform init terraform/static-web'
                        sh 'terraform apply terraform/static-web/ --auto-approve'
                    }
                    else {
                        sh 'terraform destroy terraform/static-web/ --auto-approve'
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