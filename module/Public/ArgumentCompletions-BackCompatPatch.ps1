###
 # Modified from https://powershell.one/powershell-internals/attributes/auto-completion#powershell-7-shortcut-for-windows-powershell
 #
 # Not sure if this will be used, but will be useful (and forgotten) if needed
 ##

try
{
    [void] [System.Management.Automation.ArgumentCompletionsAttribute];
}
catch
{

# Are we running in Windows PowerShell?
if ($PSVersionTable.PSEdition -ne 'Core')
{
    # Add the attribute [ArgumentCompletions()]:
    $code = <# csharp #> @'
using System;
using System.Collections.Generic;
using System.Management.Automation;

public class ArgumentCompletionsAttribute : ArgumentCompleterAttribute
{

    private static ScriptBlock _createScriptBlock(params string[] completions)
    {
        string text = "\"" + string.Join("\",\"", completions) + "\"";
        string code = "param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams);@(" + text + ") -like \"*$WordToComplete*\" | Foreach-Object { [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_) }";
        return ScriptBlock.Create(code);
    }

    public ArgumentCompletionsAttribute(params string[] completions) : base(_createScriptBlock(completions))
    {

    }
    }
'@

        $null = Add-Type -TypeDefinition $code *>&1
    }

}
