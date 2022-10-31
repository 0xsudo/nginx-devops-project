pipeline {
    agent any
    parameters {
        choice(
            name: 'Terraform_Action',
            choices: "apply\ndestroy",
            description: 'Create or destroy the infrastructure'
        )
    }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', credentialsId: 'localhost_pk', url: 'git@github.com:0xsudo/nginx-devops-project.git'
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -f nginx/Dockerfile -t kaokakelvin/nginx-image:""$BUILD_NUMBER"" --no-cache .'
            }
        }

        stage('Docker Publish') {
            steps {
                withDockerRegistry([credentialsId: "devopsrole-dockerhub", url: ""]) {
                    sh 'docker push kaokakelvin/nginx-image:""$BUILD_NUMBER""'
                }
            }
        }

        stage('Terraform') {
            steps {
                script {
                    if (params.Terraform_Action == "apply") {
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
                    // sh 'ansible-playbook -i ansible/inventory-aws_ec2.yaml -i ansible/all_servers_aws_ec2 ansible/ec2-playbook -vvv'
                    ansiblePlaybook installation: 'ansible', playbook: 'ansible/ec2-playbook', inventory: 'ansible/all_servers_aws_ec2', extras: '--inventory ansible/inventory-aws_ec2.yaml -vvv'
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