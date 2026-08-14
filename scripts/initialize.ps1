echo "Script called"
ls env:

echo "Create solution .\src\${env:PROJECT_NAME}.slnx"
Rename-Item .\src\Solution.slnx ".\src\${env:PROJECT_NAME}.slnx"