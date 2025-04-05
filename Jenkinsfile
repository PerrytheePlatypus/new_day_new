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
                    bat '''
                        set PATH=%AZURE_CLI_PATH%;%SYSTEM_PATH%;%TERRAFORM_PATH%;%PATH%
                        terraform init
                    '''
                }
            }
        }

        stage('Terraform Plan & Apply') {
            steps {
                dir('assign3') {
                    bat '''
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

                    // Debug: Check ZIP file exists
                    bat '''
                        echo Checking published output:
                        dir out
                        echo Checking ZIP file:
                        dir WebApplication1.zip
                    '''
                }
            }
        }

        stage('Deploy to Azure App Service') {
            steps {
                withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS_ID)]) {
                    powershell '''
                        $env:PATH = "$env:AZURE_CLI_PATH;$env:SYSTEM_PATH;$env:TERRAFORM_PATH;$env:PATH"

                        # Optional: Display info for debugging
                        Write-Host "Checking workspace ZIP path..."
                        Get-ChildItem "$env:WORKSPACE/WebApplication1/WebApplication1.zip"

                        # Deploy the ZIP file to Azure App Service
                        az webapp deploy `
                            --resource-group $env:RESOURCE_GROUP `
                            --name $env:APP_SERVICE_NAME `
                            --src-path "$env:WORKSPACE/WebApplication1/WebApplication1.zip" `
                            --type zip
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
