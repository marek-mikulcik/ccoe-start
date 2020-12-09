# Introduction
Review mapping in docker-compose
Script is mapped in /usr/app/aci folder

# Getting Started
Run commands:
az extension add --name azure-devops
az devops configure --defaults organization=https://dev.azure.com/swissre/
az login

/usr/app/aci/create.sh your-subscription-id "your-devops-project-name"