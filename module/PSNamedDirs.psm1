#Requires -Module Configuration -Version 6

Import-LocalizedData -BindingVariable Strings -FileName Strings -ErrorAction Ignore

# Get all module components
@( 'Classes', 'Public', 'Private' )                                     `
    | ForEach-Object { Get-ChildItem -Path "$PSScriptRoot\${_}\*.ps1" } `
    | Foreach-Object { . $_.FullName }

# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function *-* -Variable NamedDirs
