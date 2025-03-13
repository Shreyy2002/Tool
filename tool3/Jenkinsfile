pipeline {
    agent {
        label 'devops'
    }
    tools {
        git 'Git'
    }
    environment {
        AWS_ACCESS_KEY_ID = credentials('awscredid')
        AWS_SECRET_ACCESS_KEY = credentials('awscredpass')
        AWS_DEFAULT_REGION = 'ap-south-1'
    }
    stages {
        stage('git version') {
            steps {
                sh 'git --version'
            }
        }   
    
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Copy pem file to tomcat directory') {
            steps {
                sh 'cp /home/shrey_linux/SetupMonitor/tool.pem'
            }
        }
        stage('Create Infra') {
            steps {
                dir('ubuntu') {
                    sh 'terraform init'
                    sh 'terraform validate'
                    sh 'terraform plan'
                    sh 'terraform apply -auto-approve' 
                }
            }
        }
        
        stage('Verify Host') {
            steps {
                dir('tomcat') {
                    sh 'python3 ec2.py'
                }
            }
        }

        stage('Install Tomcat') {
            steps {
                dir('tomcat') {
                    //sh 'sudo -i -u ubuntu bash -c "cd $WORKSPACE/tomcat && ansible-playbook -i ec2.py playbook/tomcatdemo.yml"'
                    sh 'sudo chmod +x ec2.py && chmod 600 tool.pem && ansible-playbook -i ec2.py playbook/tomcatdemo.yml'
                }
            }
        }

        stage('Install NodeExporter') {
            steps {
                dir('tomcat') {
                    //sh 'sudo -i -u ubuntu bash -c "cd $WORKSPACE/tomcat && ansible-playbook -i ec2.py playbook/node_exporter.yml"'
                    sh 'sudo chmod +x ec2.py && chmod 600 tool.pem && ansible-playbook -i ec2.py playbook/node_exporter.yml'
                }       
            }
        }

        stage('Install Prometheus') {
            steps {
                dir('tomcat') {
                    sh 'sudo chmod +x ec2.py && chmod 600 tool.pem && ansible-playbook -i ec2.py playbook/prometheus.yml'
                }       
            }
        }

        stage('Install Grafana') {
            steps {
                dir('tomcat') {
                    sh 'sudo chmod +x ec2.py && chmod 600 tool.pem && ansible-playbook -i ec2.py playbook/grafana.yml'
                }           
            }
        }
    }
}
