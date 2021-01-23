using namespace System.Management.Automation

class ValidateDirectoryExistsAttribute : ValidateArgumentsAttribute
{
    [Void] Validate([object] $Argument, [EngineIntrinsics]$EngineIntrinsics)
    {
        if(!($Argument) -or !(Test-Path -LiteralPath $Argument))
        {
            throw [ParameterBindingException]::new("Invalid directory: `"$Argument`"")
        }
    }
}
