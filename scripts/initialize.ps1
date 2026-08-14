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
     $_ = Set-Content $filename $content
     Write-Host "Replaced placehoders in $filename"
}

Write-Host "Script called with environment"
ls env:

Write-Host "Create solution ${env:PROJECT_NAME}.slnx"
Rename-Item src\Solution.slnx "${env:PROJECT_NAME}.slnx"

Write-Host "Patch README.md"
Move-Item README-Project.md README.md -Force
Replace README.md

Write-Host "Patch documentation"
Replace docfx_project\index.md
Replace docfx_project\docfx.json

Write-Host "Remove initialization"
Remove-Item .github\workflows\initialization.yml -Force

Write-Host "`e[31mERROR: Something went wrong`e[0m"
Write-Host "`e[33mWARNING: Check this`e[0m"
Write-Host "`e[32mSUCCESS: Initialization complete`e[0m"
