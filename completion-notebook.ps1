using namespace System.IO
using namespace System.Management.Automation
<# # ***Semantics preserving path completions*** #>
<# ## Original Prompt Expression #>
#region Formatting

function Write-HeaderHost()
{
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory, Position = 0)]
        [String] $Header,
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory, Position = 1)]
        [String] $Message,

        [ValidateNotNullOrEmpty()]
        $HeaderStyle = ($PSStyle.Foreground.Cyan + $PSStyle.Bold),
        [ValidateNotNullOrEmpty()]
        $MessageStyle = ($PSStyle.Foreground.White)
    )
    Write-Host "$($HeaderStyle)${Header}:$($PSStyle.Reset) $($MessageStyle)${Message}$($PSStyle.Reset)"
}
Set-Alias Log Write-HeaderHost;

#endregion Formatting

class CanonPath
{
    CanonPath([String] $Raw, [String] $Canonicalized)
    {
        $this.raw   = $Raw
        $this.canon = $Canonicalized
    }
}

$toCompleteRaw = './../../../vscode-'
Log "Input" "       $toCompleteRaw"

$toCompleteRawDir = $toCompleteRaw -Replace "[^\/\\]+`$", ''
Log "Dir" "         ${toCompleteRawDir}"

$toComplete = $toCompleteRaw -replace "^\.\.[\\\/]+",  ((Get-Item $PWD).Directory + "/") `
                             -replace "^\.[\\\/]+",    ((Get-Item $PWD).Fullname  + "/")
Log "Expanded" "     ${toComplete}"

$toCompleteDir = $toComplete -Replace "[^\/\\]+`$", ''
Log "Expanded" "     ${toCompleteDir}"

$completedRaw = @(Get-Item "$toComplete*").FullName.ForEach{
    [IO.Path]::GetDirectoryName($toComplete) + '\' + 
    [IO.Path]::GetRelativePath(($toComplete -replace '[\/\\][^\\\/]+$', ''), $_ ) 
}
Write-Host "$($PSStyle.Foreground.Cyan)Completions (Raw):$($PSStyle.Reset)$(
  $completedRaw.ForEach{ "`n $($PSStyle.Foreground.DarkGray )-$($PSStyle.Reset) $_" }
)"
$wordToComplete = './.'
$toComplete = $wordToComplete
$toComplete = $toComplete -replace "^\.\.[\\\/]+",  ((Get-Item $PWD).Directory + "/") `
                          -replace "^\.[\\\/]+",    ((Get-Item $PWD).Fullname  + "/")

Write-Host -F Gray "Resolved Input Path: $toComplete"
            @(@(Get-Item $toComplete*).FullName).ForEach{
                [IO.Path]::GetRelativePath(($toComplete -replace '[\\\/][^\\\/]+$', '' ), $_ )
            }
function Get-RawCompletionsForPath
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        $PathFragment
    )

    $FullPaths = (Get-Item $PathFragment*).FullName
    $Output = $FullPaths

    if($PathFragment -like './*' -or $PathFragment -like '../*')
    {
        [IO.Path]::GetRelativePath

        $Output = $Output.ForEach{ $_ -replace '^\.[\\\/]', "$PWD/" }
    }
}
<# ## Build test input #>
# Simulate partial path input of hidden leaf path in current working directory
$wordToComplete = './.'
Get-RawCompletionsForPath $wordToComplete
<# # Unused #>
<#
    function Expand-RelativePathDots()
    {
        [CmdletBinding(DefaultParameterSetName = 'PathString')]
        param(
            [Parameter(Mandatory, Position = 0, ValueFromPipeline, Alias = 'Path', ParameterSetName = 'PathString')]
            $PathString,
            [Parameter(Mandatory, Position = 0, ValueFromPipeline, Alias = 'Path', ParameterSetName = 'PathInfo')]
            $PathInfo
        )

        $ResolvedPath = $PathString ? $PathString : $PathInfo

        (Get-Item $ResolvedPath).FullName
    }
#>