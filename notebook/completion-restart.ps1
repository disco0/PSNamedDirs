using namespace System.IO
using namespace System.Management.Automation
<#   #>
class CanonPath
{
    CanonPath([String] $Raw, [String] $Canonicalized)
    {
        $this.raw   = $Raw
        $this.canon = $Canonicalized
    }
}

