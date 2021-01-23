using namespace System.Management.Automation

function Get-NamedDir
{
    [CmdletBinding()]
    param(
        [WildcardPattern()]
        [Parameter(Mandatory, Position = 0)]
        [String] $Name
    )

    $Global:PSNamedDirs.GetEnumerator().Where{ $_.Key -like "$Name" }
}
