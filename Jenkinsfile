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
                git branch: 'main', credentialsId: 'jenkinsrole-git', url: 'git@github.com:0xsudo/nginx-devops-project.git'
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -f nginx/Dockerfile -t kaokakelvin/nginx-image --no-cache .'
            }
        }

        stage('Docker Publish') {
            steps {
                withDockerRegistry([credentialsId: "devopsrole-dockerhub", url: ""]) {
                    sh 'docker push kaokakelvin/nginx-image'
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
                    sh 'ansible-playbook -i ansible/all-ec2-servers -i ansible/inventory-aws_ec2.yaml ansible/ec2-playbook -vvv'
                    // ansiblePlaybook(
                    //     installation: 'ansible',
                    //     playbook: 'ansible/ec2-playbook',
                    //     inventory: 'ansible/inventory-aws_ec2.yaml',
                    //     inventory: 'ansible/all-ec2-servers',
                    //     credentialsId: '636181284446'
                    // ) 
                    // could not find a way to parse two inventories using the ansible plugin
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