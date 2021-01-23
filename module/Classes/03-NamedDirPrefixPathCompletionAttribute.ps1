using namespace System.Collections
using namespace System.Collections.Generic
using namespace System.Drawing.Printing
using namespace System.Management.Automation
using namespace System.Management.Automation.Language

class NamedDirPathCompletionAttribute : IArgumentCompleter
{
    static [bool] ShouldCompleteNamedDir([string] $WordToComplete)
    {
        return [NamedDirs]::PossibleNamedDir($WordToComplete)
    }

    [IEnumerable[CompletionResult]] CompleteArgument(
        [string]      $CommandName,
        [string]      $ParameterName,
        [string]      $WordToComplete,
        [CommandAst]  $CommandAst,
        [IDictionary] $FakeBoundParameters
    ) {
        $wildcard          = ("*" + $wordToComplete + "*")
        $CompletionResults = [List[CompletionResult]]::new()

        #region Generic Path Completion
        if([NamedDirPathCompletionAttribute]::ShouldCompleteNamedDir($WordToComplete))
        {
            # @TODO: How 2 hook builtin path completions???
            $toComplete = $wordToComplete
            $toComplete = $toComplete -replace "^\.\.[\\\/]+",  ((Get-Item $PWD).Directory + "/") `
                                      -replace "^\.[\\\/]+",    ((Get-Item $PWD).Fullname  + "/")
            @(@(Get-Item $toComplete*).FullName).ForEach{
                [IO.Path]::GetRelativePath(($toComplete -replace '[\\\/][^\\\/]+$', '' ), $_ )
            }
        }
        #endregion Generic Path Completion
        else
        #region Named Dir Completion
        {
            $Global:PSNamedDirs.GetEnumerator().Where{

            }
        }
        #endregion Named Dir Completion

        # ForEach-Object {$CompletionResults.Add([CompletionResult]::new("'" + $_ + "'")}

        return $CompletionResults
    }
}
