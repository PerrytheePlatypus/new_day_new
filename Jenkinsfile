pipeline {
    agent any

    environment {
        AZURE_CREDENTIALS_ID = '05-10-2025-adi-april'
        TERRAFORM_VERSION = '1.7.5'
        GIT_REPO_URL = 'https://github.com/PerrytheePlatypus/new_day_new.git'
        GIT_BRANCH = 'main'
    }

    stages {
        stage('Clean Workspace') {
            steps {
                deleteDir() // Ensure workspace is clean before starting
            }
        }

        stage('Checkout Code') {
            steps {
                git branch: GIT_BRANCH, url: GIT_REPO_URL
            }
        }

        stage('Verify Terraform Files') {
            steps {
                dir('terraform') {
                    bat 'dir' // List contents of terraform directory to verify files exist
                }
            }
        }

        stage('Install Terraform') {
            steps {
                bat '''
                    powershell -Command "Invoke-WebRequest -Uri 'https://releases.hashicorp.com/terraform/%TERRAFORM_VERSION%/terraform_%TERRAFORM_VERSION%_windows_amd64.zip' -OutFile 'terraform.zip'"
                    powershell -Command "Expand-Archive -Path 'terraform.zip' -DestinationPath 'C:\\terraform' -Force"
                    setx PATH "%PATH%;C:\\terraform" /M
                '''
            }
        }

        stage('Azure Login') {
            steps {
                withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS_ID)]) {
                    bat '''
                        az login --service-principal -u "%AZURE_CLIENT_ID%" -p "%AZURE_CLIENT_SECRET%" --tenant "%AZURE_TENANT_ID%"
                        az account set --subscription "%AZURE_SUBSCRIPTION_ID%"
                    '''
                }
            }
        }

        stage('Terraform Init') {
            steps {
                dir('terraform') { // Navigate to the terraform directory
                    bat '''
                        C:\\terraform\\terraform.exe init
                    '''
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('terraform') { // Navigate to the terraform directory
                    bat '''
                        C:\\terraform\\terraform.exe plan -var="resource_group_name=rg-jenkins" -var="location=Central US" -var="app_service_plan_name=aditya-2025-jan-cpg" -var="app_service_name=webapijenkin02202505"
                    '''
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') { // Navigate to the terraform directory
                    bat '''
                        C:\\terraform\\terraform.exe apply -auto-approve -var="resource_group_name=rg-jenkins" -var="location=Central US" -var="app_service_plan_name=aditya-2025-jan-cpg" -var="app_service_name=webapijenkin02202505"
                    '''
                }
            }
        }

        stage('Publish .NET 8 Web API') {
            steps {
                dir('webapi') { // Navigate to the webapi directory
                    bat '''
                        dotnet publish -c Release -o out
                        powershell Compress-Archive -Path "out\\*" -DestinationPath "webapi.zip" -Force
                    '''
                }
            }
        }

        stage('Deploy to Azure App Service') {
            steps {
                withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS_ID)]) {
                    bat '''
                        az webapp deploy --resource-group rg-jenkins --name webapijenkin02202505 --src-path "%WORKSPACE%\\webapi\\webapi.zip" --type zip
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '''
                =========================================
                Deployment Successful!
                Your application is available at:
                https://webapijenkin02202505.azurewebsites.net
                =========================================
            '''
        }
        failure {
            echo '''
                =========================================
                Deployment Failed!
                Please check the logs for details.
                =========================================
            '''
        }
    }
}
