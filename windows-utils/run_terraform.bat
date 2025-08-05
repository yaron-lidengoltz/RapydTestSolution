@echo off
setlocal

:: ===== SET YOUR AWS CREDENTIALS =====
set AWS_ACCESS_KEY_ID=AAAAA
set AWS_SECRET_ACCESS_KEY=BBBBB
set AWS_DEFAULT_REGION="eu-west-1"




:: ===== GET RELATIVE PATH ARGUMENT =====
if "%~1"=="" (
    echo ❌ Please provide the path to the folder containing main.tf
    echo Example: run_terraform.bat infra/terraform
    pause
    exit /b 1
)

:: ===== RESOLVE PATH AND MOVE INTO TARGET DIRECTORY =====
set "TF_DIR=%~1"
cd /d "%TF_DIR%" || (
    echo ❌ Failed to access folder: %TF_DIR%
    pause
    exit /b 1
)

:: ===== RUN TERRAFORM COMMANDS =====
echo 🚀 Initializing Terraform...
terraform init || goto :error

echo 🔍 Validating Terraform...
terraform validate || goto :error

echo 🛠️ Planning Terraform...
terraform plan || goto :error

echo 🛠️ Applying Terraform...
terraform apply -auto-approve || goto :error

echo.
echo ✅ Terraform apply complete. If you saw your AWS Account ID, the credentials work.
pause
exit /b 0

:error
echo ❌ An error occurred during Terraform execution.
pause
exit /b 1
