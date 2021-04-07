using namespace System.IO
using namespace System.Management.Automation
<# ## Prelude: Original Prompt Expressions #>
<# ### Formatting #>
$Style_Key   = $PSStyle.Foreground.Cyan + $PSStyle.Bold;
$Style_Value = $PSStyle.Foreground.FromRgb(130, 130, 130);

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
        $HeaderStyle = $Style_Key,
        
        [ValidateNotNullOrEmpty()]
        $MessageStyle = $Style_Value
    )
    Write-Host "$($HeaderStyle)${Header}:$($PSStyle.Reset) $($MessageStyle)${Message}$($PSStyle.Reset)"
}
Set-Alias Log Write-HeaderHost;
<# ### CanonPath #>
class CanonPath
{
    CanonPath([String] $Raw, [String] $Canonicalized)
    {
        $this.raw   = $Raw
        $this.canon = $Canonicalized
    }
}
<# ### Run #>
# Input
$toCompleteRaw = './../../../vscode-'

Log "Input" "       $toCompleteRaw"

# Input Dir
$toCompleteRawDir = $toCompleteRaw -Replace "[^\/\\]+`$", ''

Log "Dir" "         ${toCompleteRawDir}"

# Resolve Input
$toComplete = $toCompleteRaw -replace "^\.\.[\\\/]+", ((Get-Item $PWD).Directory + "/") `
                             -replace "^\.[\\\/]+",   ((Get-Item $PWD).Fullname  + "/")

Log "Expanded" "    ${toComplete}"

# Resolve Input Dir
$toCompleteDir = $toComplete -Replace "[^\/\\]+`$", ''

Log "Expanded Dir" "${toCompleteDir}"

$completedRaw = (@(Get-Item "$toComplete*").FullName).ForEach{
    [IO.Path]::GetDirectoryName($toComplete) + '\' +
        [IO.Path]::GetRelativePath(($toComplete -replace '[\/\\][^\\\/]+$', ''), $_ )
}

Log "Completions (Raw)" "$( $completedRaw.ForEach{ "`n - $_" } )";

$wordToComplete = './.'
$toComplete = $wordToComplete
$toComplete = $toComplete -replace "^\.\.[\\\/]+",  ((Get-Item $PWD).Directory + "/") `
                          -replace "^\.[\\\/]+",    ((Get-Item $PWD).Fullname  + "/")

Log "Resolved Input Path" "$(
    @(@(Get-Item $toComplete*).FullName).ForEach{
        " - " + [IO.Path]::GetRelativePath(($toComplete -replace '[\\\/][^\\\/]+$', '' ), $_ )
    }
)"
<# # ***Semantics preserving path completions*** #>
Write-Host -F Magenta "$($PSStyle.Underline) ----------- MAIN -----------$($PSStyle.UnderlineOff)"
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
        # [IO.Path]::GetRelativePath

        $Output = $Output.ForEach{ $_ -replace '^\.[\\\/]', "$PWD/" }
    }

    $Output
}
<# ## Build test input #>
# Simulate partial path input of hidden leaf path in current working directory
# $wordToComplete = './.'
# Get-RawCompletionsForPath $wordToComplete
<# # Unused #>
<#
``` ps
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
```
#>
