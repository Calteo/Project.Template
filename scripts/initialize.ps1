function Replace()
{
     param(
        [Parameter(Mandatory)]
        [string]$filename
    )
    $content = Get-Content $filename -Raw

    [regex]::Replace($content, '\{\{(?<name>[^}]+)\}\}',
        {
            param($match)

            $envName = $match.Groups['name'].Value
            $value = [Environment]::GetEnvironmentVariable($envName)
            if ($value -eq $null)
            { 
                $value = "{{$envName}}"
            }
            $value
        })     
     Set-Content $filename $content
     Write-Host "Replaced placehoders in $filename"
}

Write-Host "Script called with environment"
ls env:

Write-Host "Create solution ${env:PROJECT_NAME}.slnx"
Rename-Item .\src\Solution.slnx "${env:PROJECT_NAME}.slnx"

Write-Host "Patch README.md"
Move-Item README-Project.md README.md -Force
Replace README.md

Write-Host "Patch documentation"
Replace docfx_project\index.md
Replace docfx_project\docfx.json
