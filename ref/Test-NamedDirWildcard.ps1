using namespace System.Management.Automation
using namespace System.Collections.Generic

$BoldRed    = ($PSStyle.Foreground.Red + $PSStyle.Bold)
$BoldRedOff = ($PSStyle.Bold)

$VerbFG     = $PSStyle.Foreground.$($Host.PrivateData.VerboseForegroundColor)
$VerbBG     = $PSStyle.Background.$($Host.PrivateData.VerboseBackgroundColor)
$VerbStyle  = $VerbBG + $VerbFG

$PathStyle  = @( ($PSStyle.Underline), ($PSStyle.UnderlineOff) )

<#
  .SYNOPSIS
    Demonstrates how to write a command that works with paths that allow
    wildards and must exist.
  .DESCRIPTION
    This command also demonstrates how you need to supply a LiteralPath
    parameter when your Path parameter accepts wildcards.  This is in order
    to handle paths like foo[1].txt.  If you pass this path to the Path
    parameter, it will fail to find this file because "[1]" is interpreted
    as a wildcard spec e.g it resolves to foo1.txt.  The LiteralPath parameter
    is used in this case as it does not interpret wildcard chars.
  .EXAMPLE
    C:\PS> Import-FileWildcard -LiteralPath ..\..\Tests\foo[1].txt -WhatIf
    This example shows how to use the LiteralPath parameter with a path
    that happens to use the wildcard chars "[" and "]".
#>
function Get-NamedDirWildcardValues
{
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Path')]
    param(
        # Specifies a path to one or more locations. Wildcards are permitted.
        [Parameter(
            Mandatory,
            Position = 0,
            ParameterSetName = 'Path',
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            HelpMessage = 'Path to one or more locations.')]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string[]] $Path,

        # Specifies a path to one or more locations. Unlike the Path parameter, the value of the
        # LiteralPath parameter is used exactly as it is typed. No characters are interpreted as
        # wildcards. If the path includes escape characters, enclose it in single quotation marks.
        # Single quotation marks tell Windows PowerShell not to interpret any characters as escape
        # sequences.
        [Parameter(
            Mandatory,
            Position = 0,
            ParameterSetName = 'LiteralPath',
            ValueFromPipelineByPropertyName,
            HelpMessage = 'Literal path to one or more locations.')]
        [Alias('PSPath')]
        [ValidateNotNullOrEmpty()]
        [string[]] $LiteralPath
    )

    begin
    {
    }

    process
    {
        # Modify [CmdletBinding()] to [CmdletBinding(SupportsShouldProcess=$true, DefaultParameterSetName='Path')]
        $paths = @()
        if ($psCmdlet.ParameterSetName -eq 'Path')
        {
            Write-Verbose "Processing Parameters: -Path"
            foreach ($aPath in $Path)
            {
                Write-Verbose "-Path $($PathStyle[0])$($aPath)$($PathStyle[-1])"
                if (!(Test-Path -Path $aPath))
                {
                    $local:msg = "Cannot find path '$aPath' because it does not exist."
                    $ex        = [ItemNotFoundException]::new($local:msg)
                    $category  = [ErrorCategory]::ObjectNotFound
                    $errRecord = [ErrorRecord]::new($ex, 'PathNotFound', $category, $aPath)

                    Write-Verbose "-Path $($PathStyle[0])$($aPath)$($PathStyle[-1]) ${BoldRed}Failed:${BoldRedOff}${VerbStyle}${local:msg}"

                    $psCmdlet.WriteError($errRecord)
                    continue
                }

                # Resolve any wildcards that might be in the path
                $paths += $psCmdlet.SessionState.Path.GetResolvedProviderPathFromPSPath($aPath, [ref]($null))
            }
        }
        else
        {
            foreach ($aPath in $LiteralPath)
            {
                Write-Verbose "Processing Parameters: -LiteralPath"
                if (!(Test-Path -LiteralPath $aPath))
                {
                    $local:msg = "Cannot find path '$aPath' because it does not exist."

                    $ex        = [ItemNotFoundException]::new($local:msg)
                    $category  = [ErrorCategory]::ObjectNotFound
                    $errRecord = [ErrorRecord]::new($ex, 'PathNotFound', $category, $aPath)

                    Write-Verbose "-LiteralPath $($PathStyle[0])$($aPath)$($PathStyle[-1]) ${BoldRed}Failed:${BoldRedOff}${VerbStyle}${local:msg}"

                    $psCmdlet.WriteError($errRecord)
                    continue
                }

                # Resolve any relative paths
                $paths += $psCmdlet.SessionState.Path.GetUnresolvedProviderPathFromPSPath($aPath)
            }
        }

        foreach ($aPath in $paths)
        {
            if ($pscmdlet.ShouldProcess($aPath, 'Operation'))
            {
                # Process each path
                $aPath
            }
        }
    }

    end
    {
    }
}

function Test-GetNamedDirWildcardValues()
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [List[String]] $PathInputs = [List[String]]@("./*", "./*/*.ps1")
    )

    Write-Host "-Path Inputs:"
    foreach($inputPath in $PathInputs)
    {
        Write-Host -F Cyan " • ${PathStyle[0]}${inputPath}${PathStyle[-1]}"
        $resolvedPaths = Get-NamedDirWildcardValues -Path $inputPath
        foreach($resolvedPath in $resolvedPaths)
        {
            Write-Host "   - ${PathStyle[0]}${resolvedPath}${PathStyle[-1]}"
        }
    }
}
