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
                        sh 'terraform -chdir=./terraform/static-web apply --auto-approve'
                    }
                    else {
                        sh 'terraform -chdir=./terraform/static-web destroy --auto-approve'
                    }
                }
            }
        }

        stage('Ansible'){
            steps{
                retry(count: 10) {
                    ansiblePlaybook(
                        playbook: 'ansible/static-web/ec2-site-playbook.yaml',
                        inventory: 'ansible/aws-ec2-inventory.yaml',
                        credentialsId: 'AKIAZIH24AZPACRJM7WT'
                    )
                }
            }
        }
    }

}