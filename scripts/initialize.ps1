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
     Write-Host "`e[34mReplaced placehoders in $filename`e[0m"
     return $null
}

Write-Host "`e[33mScript called with environment`e[0m"
ls env:

Write-Host "`e[34mCreate solution ${env:PROJECT_NAME}.slnx`e[0m"
Rename-Item src\Solution.slnx "${env:PROJECT_NAME}.slnx"

Write-Host "`e[34mPatch README.md`e[0m"
Move-Item README-Project.md README.md -Force
Replace README.md

Write-Host "`e[34mPatch documentation`e[0m"
Replace docfx_project\index.md
Replace docfx_project\docfx.json

Write-Host "`e[34mRemove initialization`e[0m"
Remove-Item .github\workflows\initialization.yml -Force
Remove-Item $PSCommandPath -Force

Write-Host "`e[32mInitialization complete`e[0m"
