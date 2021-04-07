#Requires -Module InvokeBuild, ModuleBuilder, PSScriptAnalyzer, @{ModuleName="Pester";ModuleVersion=5.1}

[CmdletBinding()]
param()

#region Config

$moduleName = 'PSNamedDirs'
$manifest   = Test-ModuleManifest -Path          $PSScriptRoot\module\$moduleName.psd1 `
                                  -ErrorAction   Ignore `
                                  -WarningAction Ignore

$script:Settings = @{
    Name          = $moduleName
    Manifest      = $manifest
    Version       = $manifest.Version
    ShouldAnalyze = $true
    ShouldTest    = $true
}

$script:Folders = @{
    PowerShell  = "$PSScriptRoot/module"
    Source      = "$PSScriptRoot/module"
    BuildOutput = '{0}/build'      -f $Script:Folders.Source
    BuildFile   = '{0}/build.psd1' -f $Script:Folders.PowerShell
    Release     = '{0}/release/{1}/{2}' -f $PSScriptRoot, $moduleName, $manifest.Version
    Docs        = "$PSScriptRoot/docs"
    Test        = "$PSScriptRoot/test"
    PesterCC    = "$PSScriptRoot/*.psm1",
                  "$PSScriptRoot/Public/*.ps1",
                  "$PSScriptRoot/Private/*.ps1",
                  "$PSScriptRoot/Classes/*.ps1"
}

$script:Discovery = @{
    HasDocs  = Test-Path ('{0}/{1}/*.md' -f $Folders.Docs, $PSCulture)
    HasTests = Test-Path ('{0}/*.Tests.ps1' -f $Folders.Test)
    ModuleBuilderScript = Test-Path ( $script:Folders.BuildFile )
}

#endregion Config

#region Base Tasks

# Validation
task Analyze -If { $script:Settings.ShouldAnalyze } {
    Invoke-ScriptAnalyzer -Path     $script:Folders.Release                     `
                          -Settings "$PSScriptRoot/ScriptAnalyzerSettings.psd1" `
                          -Recurse
}

task Test -If { $script:Discovery.HasTests -and $script:Settings.ShouldTest } {
    $PesterPreference = [PesterConfiguration]::Default
    $PesterPreference.CodeCoverage.Enabled = $true

    $Container = New-PesterContainer -Path "$($script:Folders.Test)/*/*.Test.ps1"

    Invoke-Pester -Container $Container
}

# Core Build
task Clean {
    if (Test-Path $script:Folders.Release)
    {
        Remove-Item $script:Folders.Release -Recurse
    }

    $null = New-Item $script:Folders.Release -ItemType Directory
}

task ModuleBuilder {
    $SourceDir = $Script:Folders.Source
    $Release   = $Script:Folders.Release

    Write-Host -F Magenta "[ModuleBuilderBuild] Source Dir:  $SourceDir"
    Push-Location -Path $SourceDir

    try
    {
        Write-Host -F Magenta "[ModuleBuilderBuild] Building to: ${Release}"

        Build-Module -OutputDirectory $Release               `
                     -Passthru -OutVariable CurrentBuildInfo `
            | Format-List -Property Name,Version

        Write-Host -F Magenta "Exported Commands:"
        ($CurrentBuildInfo.ExportedCommands.GetEnumerator()).ForEach{ "  " + $_.Key } `
            | Format-List | Out-String -Stream | Write-Host
    }
    finally
    {
        Pop-Location
    }
}

task CopyToRelease {
    Copy-Item -Path ('{0}/*' -f $script:Folders.PowerShell) `
              -Destination $script:Folders.Release          `
              -Recurse                                      `
              -Force
}

task BuildDocs -If { $script:Discovery.HasDocs } {
    # Workaround for handling `ERROR: Assembly with same name is already loaded` error when building
    if(!(Get-Command New-ExternalHelp -ErrorAction SilentlyContinue))
    {
        Import-Module platyPS -ErrorAction SilentlyContinue
    }

    $null = New-ExternalHelp -Path       "$PSScriptRoot\docs\$PSCulture" `
                             -OutputPath ('{0}/{1}' -f $script:Folders.Release, $PSCulture)
}

task Analyze -If { $script:Settings.ShouldAnalyze } {
    Invoke-ScriptAnalyzer -Path     $script:Folders.Release                   `
                          -Settings $PSScriptRoot\ScriptAnalyzerSettings.psd1 `
                          -Recurse
}

task DoInstall {
    $installBase = $Home
    if ($profile) { $installBase = $profile | Split-Path }

    $installPath = '{0}\Modules\{1}\{2}' -f $installBase, $script:Settings.Name, $script:Settings.Version

    Write-Host -F Magenta "Installing $('{0}/*' -f $script:Folders.Release)"
    Write-Host -F Magenta "Installing to: $installPath"


    if (-not (Test-Path $installPath))
    {
        $null = New-Item $installPath -ItemType Directory
    }

    Copy-Item -Path ('{0}\*' -f $script:Folders.Release) `
              -Destination $installPath `
              -Force `
              -Recurse

    Get-ChildItem -Recurse $script:Folders.Release | oss | Write-Host -F Magenta
}

task DoPublish {
    if (-not (Test-Path $HOME\.PSGallery\apikey.xml)) {
        throw 'Could not find PSGallery API key!'
    }

    $apiKey = (Import-Clixml $HOME\.PSGallery\apikey.xml).GetNetworkCredential().Password
    Publish-Module -Name $script:Folders.Release -NuGetApiKey $apiKey -Confirm
}

#endregion Base Tasks

#region Main Tasks

#TODO: Reincorperate Test and Analyze

task Build        -Jobs Clean, ModuleBuilder

task BuildInstall -Jobs Build, Analyze, DoInstall

task PreRelease   -Jobs Build, Analyze, Test

task Install      -Jobs PreRelease, DoInstall

task Publish      -Jobs PreRelease, DoPublish

task . Build

#endregion Main Tasks

