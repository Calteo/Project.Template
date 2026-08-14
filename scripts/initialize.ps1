$replacements = @{
    "{{PROJECT_NAME}}" = $env:PROJECT_NAME
}

function Replace()
{
     param(
        [Parameter(Mandatory)]
        [string]$filename,
    )
    $content = Get-Content $filename -Raw

        foreach ($replacement in $replacements.GetEnumerator()) {
            $content = $content.Replace(
                $replacement.Key,
                $replacement.Value
            )
        }

        Set-Content $filename $content
        echo "Replaced placehoders in $filename"
}

echo "Script called"
ls env:

echo "Create solution ${env:PROJECT_NAME}.slnx"
Rename-Item .\src\Solution.slnx "${env:PROJECT_NAME}.slnx"

echo "Patch documentation"
Replace docfx_project\index.md
