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
