$moduleName = 'PSNamedDirs'
$Script:manifestPath = "$PSScriptRoot\..\release\$moduleName\*\$moduleName.psd1"

$Script:Manifest | Format-List | Out-String -Stream | ForEach-Object { Write-Verbose $_ }

Describe 'module manifest values' {

    It 'can retrieve manfiest data' {
        Write-Verbose "Attempting to retreive manifest from path: '${manifestPath}'"
        $Script:manifest = Test-ModuleManifest -Path $manifestPath
    }

    It 'has the correct name' {
        $Script:manifest.Name | Should -Be $moduleName
    }

    It 'has the correct guid' {
        $Script:manifest.Guid | Should -Be '601cb82b-9ccc-4e3c-be79-8592a0a6c3fa'
    }
}
