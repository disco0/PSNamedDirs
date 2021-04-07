using namespace System.Management.Automation

class ValidateDirectoryNamedOrExistsAttribute : ValidateArgumentsAttribute
{
    [Void] Validate([object] $Path, [EngineIntrinsics] $EngineIntrinsics)
    {
        if(!($Path))
        {
            throw [ParameterBindingException]::new("Invalid parameter value: `"$Path`"")
        }

        # check whether the path is empty:
        if([string]::IsNullOrWhiteSpace($Path))
        {
            # whenever something is wrong, throw an exception:
            Throw [System.ArgumentNullException]::new()
        }

        # Check if input appears to be a named directory form, and bailout if so (where it will
        # continue to catch fire in function body instead)
        if([NamedDirs]::PossibleNamedDir($Path))
        {
            return
        }

        # check whether the path exists:
        if(!(Test-Path -Path $Path) -or
            !((Get-Item -ErrorAction SilentlyContinue -LiteralPath $Path) -is [DirectoryInfo]))
        {
            throw [ParameterBindingException]::new(
                "Invalid parameter value: `"$Path`"",
                [System.IO.DirectoryNotFoundException]::new() );
        }
    }
}
