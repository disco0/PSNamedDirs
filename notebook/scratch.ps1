using namespace System.Management.Automation
using namespace System.IO

. ./Write-HeaderHost.ps1

function Build-PathCompletion()
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [String] $PathFragnent
    )

    $base, $tail = $PathFragnent -split '[\/]', -2;

    Write-Verbose "Base: $base";
    Write-Verbose "Tail: $tail";

    # Default
    $pathTarget = $base

    # If no $tail -
}
