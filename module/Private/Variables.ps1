using namespace System.IO

#region Configuration

# Don't clobber
if(!(Get-Variable -ErrorAction SilentlyContinue PSNamedDirs -Scope Global))
{
    <##
     # Still not 100% on the scoping for this, initially was Script but its global now in the interest
     # of accessibility (especially so until configuration control functions are added)
     #
     # @TODO: Before publishing remove user defaults and maybe replace with some useful universal ones
     #>

    # [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", Target = "PSNamedDirs")]
    $Global:PSNamedDirs = [NamedDirs] @{ };

    <##
     # Initialize "common" (read: my personal paths, for now) named directories, if
     # found in filesystem
     #>
    @{
        git     = [Path]::Combine($HOME, "git")
        gl      = [Path]::Combine($HOME, "git.local")
        dotfile = [Path]::Combine($HOME, "dotfile")
        dot     = [Path]::Combine($HOME, "dotfile")
        pwsh    = [Path]::Combine($HOME, "dotfile", "pwsh")
    }.GetEnumerator().ForEach{
        if((Test-Path $_.Value) -And ((Get-Item $_.Value) -is ([DirectoryInfo])))
        {
            $Global:PSNamedDirs.set($_.Key, $_.Value)
        }
    }

}

#endregion Configuration
