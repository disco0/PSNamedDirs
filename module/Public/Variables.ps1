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
    $Global:PSNamedDirs = [NamedDirs] @{
        git     = "$HOME/git"
        gl      = "$HOME/git.local"
        dotfile = "$HOME/dotfile"
        dot     = "$HOME/dotfile"
        pwsh    = "$HOME/dotfile/pwsh"
    };

}

#endregion Configuration
