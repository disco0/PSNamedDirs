using namespace System.IO

<##
 # @TODO: Finish adding:
 # - Completion Provider
 # - Transformation Attribute?
 # - If not possible or method used would make configuration less dynamic just validate
 #   inside the function like a normal person
 #>
function Set-NamedLocation()
{
    [CmdletBinding()]
    param(
        [ValidateDirectoryNamedOrExists()]
        [Parameter(Mandatory, Position = 0)]
        [String] $Path
    )

    # Microsoft.PowerShell.Management\Set-Location -Path $Global:PSNamedDirs.parse($Path)
    Microsoft.PowerShell.Management\Push-Location -Path $Global:PSNamedDirs.parse($Path)
}
