using namespace System.IO
using namespace System.Collections.Generic
using namespace System.Management.Automation

#region NamedDirs

class NamedDirs : Dictionary[String, DirectoryInfo]
{
    # @Constructor Create instance with no initial configuration
    NamedDirs(): base() { [void] $this }

    # @Constructor Create instance with initial values
    NamedDirs([HashTable] $config): base()
    {
        foreach($key in $config.Keys)
        {
            ([Dictionary[String, DirectoryInfo]] $this).Add($key, $config[$key])
        }
    }

    [String] parse([String] $Path)
    {
        $Path = $Path -Replace '[\\\/]+$', '';

        $Name = [NamedDirs]::NamedDirPattern.Match($Path).Groups.Where{ $_.name -eq 'name' }.Value;

        # Treat as normal path if base is not formed as a NamedDir, or is not a defined NamedDir
        if($null -eq $Name -or $Name.length -eq 0 -or $null -eq $this[$name])
        {
            return [String] $Path;
        }
        else
        {
            # Try accessing configured value
            $DirValue = $this.GetEnumerator().Where{ $_.Key -eq $Name }.Value

            if(!$DirValue)
            {
                return [String] $Path;
            }
            $ExpandedPath = [IO.Path]::Join($DirValue, $Path.Substring($Name.Length + 1));

            return [String] $ExpandedPath
        }
    }

    #region Static

    static [regex] $NamedDirPattern = [regex]::new('^~(?<name>[^\s\n\\\/]+)');

    static [bool] PossibleNamedDir([String] $Path)
    {
        return [NamedDirs]::NamedDirPattern.Match($Path).Success
    }

    #endregion Static
}

#endregion NamedDirs

#region Overengineered (TODO: Return to this if simple class has problems)

# class NamedDirsDisabled : Dictionary[String, DirectoryInfo]
# {
#     NamedDirsDisabled() : base()
#     {
#     }

#     #region Internal

#     static hidden [DirectoryInfo] CheckValue([String] $DirString)
#     {
#         $Resolved = Get-Item -LiteralPath $DirString    `
#             | Where-Object { $_ -is [DirectoryInfo] }   `
#             | Select-Object -First 1;

#         if($Resolved -is [DirectoryInfo])
#         {
#             return $Resolved
#         }
#         else
#         {
#             throw "Failed to resolve Directory string value to ``DirectoryInfo`` type."
#         }
#     }

#     hidden UpdateConfig([string] $Key, [DirectoryInfo] $Value)
#     {
#         # Remove existing entry if defined
#         if(([Dictionary[String, DirectoryInfo]]$this).ContainsKey($Key))
#         {
#             if(([Dictionary[String, DirectoryInfo]]$this).Remove($Key))
#             {
#                 throw "Failed to remove $Key entry from NamedDirsDisabled instance."
#             }
#         }

#         $this.add($Key, $Value)
#     }

#     #endregion Internal

#     #region External

#     #region Add

#     [void] set([String] $Key, [String] $Path)
#     {
#         # Validate $Path before any modification
#         [DirectoryInfo] $Value = [NamedDirsDisabled]::CheckValue($Path)

#         $this.UpdateConfig($Key, $Value)
#     }

#     [void] set([String] $Key, [DirectoryInfo] $Path)
#     {
#         $this.UpdateConfig($Key, $Path)
#     }

#     # Chainable versions
#     [NamedDirsDisabled] push([String] $Key, [String] $Path)
#     {
#         $this.set($Key, $Path)

#         return $this
#     }

#     [NamedDirsDisabled] push([String] $Key, [DirectoryInfo] $Path)
#     {
#         $this.set($Key, $Path)

#         return $this
#     }

#     #endregion Add

#     #region Remove

#     [void] delete([String] $Key)
#     {
#         ([Dictionary[string, DirectoryInfo]]$this).Remove($key)
#     }

#     # Chainable version
#     [NamedDirsDisabled] pull([String] $Key)
#     {
#         ([Dictionary[string, DirectoryInfo]]$this).Remove($key)

#         return $this
#     }

#     #endregion Remove

#     #region Query

#     [bool] has([String] $Name)
#     {
#         return ([Dictionary[string, DirectoryInfo]]$this).ContainsKey($Name)
#     }

#     [DirectoryInfo] get([string] $Name)
#     {
#         return $this[$Name]
#     }

#     [DirectoryInfo] resolve([string] $NamedPath)
#     {
#         $Key = [NamedDirsDisabled]::NameInPath($NamedPath);
#         if(($Key.Length -gt 0) -and $null -ne $this[$key])
#         {
#             return [DirectoryInfo] $this[$key]
#         }
#         else
#         {
#             throw "No configured directory using name '${key}'."
#         }
#     }

#     #endregion Query

#     #endregion External

#     static [string] NameInPath([String] $Path)
#     {
#         # Strip named dir prefix `~`, and everything after the first directory separator char
#         # (skipping the [System.IO.Path]::DirectorySeparatorChar as neither value should be in
#         # a directory name)
#         return $Path -replace '^~|[\/\\].+', ''
#     }
# }

#endregion Overengineered
