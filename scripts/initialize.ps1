function Replace()
{
     param(
        [Parameter(Mandatory)]
        [string]$filename
    )
    $content = Get-Content $filename -Raw

    $content = [regex]::Replace($content, '\{\{<([^>]+)>\}\}',
        {
            param($match)

            $envName = $match.Groups[1].Value
            [Environment]::GetEnvironmentVariable($envName)
        })
     
     Set-Content $filename $content
     Write-Host "Replaced placehoders in $filename" -ForegroundColor DarkGray
}

Write-Host "Script called with environment" -ForegroundColor Yellow
ls env:

Write-Host "Create solution ${env:PROJECT_NAME}.slnx"
Rename-Item .\src\Solution.slnx "${env:PROJECT_NAME}.slnx"

Write-Host "Patch README.md"
Move-Item README-Project.md README.md -Force
Replace README.md

Write-Host "Patch documentation"
Replace docfx_project\index.md
Replace docfx_project\docfc.json
