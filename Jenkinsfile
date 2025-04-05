pipeline {
    agent any

    environment {
        AZURE_CREDENTIALS_ID = '05-10-2025-adi-april'
        RESOURCE_GROUP = 'rg-jenkins'
        APP_SERVICE_NAME = 'webapijenkin02202505'
        AZURE_CLI_PATH = 'C:/Program Files/Microsoft SDKs/Azure/CLI2/wbin'
        SYSTEM_PATH = 'C:/Windows/System32'
        TERRAFORM_PATH = 'C:/Users/91907/Downloads/terraform_1.11.3_windows_386'
    }

    stages {

        stage('Terraform Init') {
            steps {
                dir('assign3') {
                    bat script: '''
                        set PATH=%AZURE_CLI_PATH%;%SYSTEM_PATH%;%TERRAFORM_PATH%;%PATH%
                        terraform init
                    '''
                }
            }
        }

        stage('Terraform Plan & Apply') {
            steps {
                dir('assign3') {
                    bat script: '''
                        set PATH=%AZURE_CLI_PATH%;%SYSTEM_PATH%;%TERRAFORM_PATH%;%PATH%
                        terraform plan
                        terraform apply -auto-approve
                    '''
                }
            }
        }

        stage('Publish .NET 8 Web API') {
            steps {
                dir('WebApplication1') {
                    bat 'dotnet restore'
                    bat 'dotnet build --configuration Release'
                    bat 'dotnet publish -c Release -o out'
                    bat 'powershell Compress-Archive -Path "out\\*" -DestinationPath "WebApplication1.zip" -Force'
                }
            }
        }

         stage('Deploy to Azure App Service') {
                steps {
                    withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS_ID)]) {
                        bat 'set PATH=%AZURE_CLI_PATH%;%SYSTEM_PATH%;%TERRAFORM_PATH%;%PATH%'
                        bat 'az webapp deploy --resource-group %RESOURCE_GROUP% --name %APP_SERVICE_NAME% --src-path %WORKSPACE%\\Webapplication1\\Webapplication1.zip --type zip'
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment Successful!'
        }
        failure {
            echo 'Deployment Failed!'
        }
    }
}
