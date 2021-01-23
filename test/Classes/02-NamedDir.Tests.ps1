using namespace System.IO
using module ..\..\release\PSNamedDirs

#region Load Module (Uncached)

Write-Host "$($PSStyle.Foreground.Magenta)Reloading PSNamedDirs module...$($PSStyle.Reset)"
$ModuleBase = "$PSScriptRoot\..\..\release"
Get-Module NamedDirs | Remove-Module -Verbose -Force
Import-Module $ModuleBase\PSNamedDirs -Verbose -ErrorAction Stop

#endregion Load Module (Uncached)

InModuleScope -Verbose -ModuleName PSNamedDirs {

Describe 'NamedDirs' -Tag Configuration, Class {

    It 'is detected at module import runtime' {
        Get-Type -TypeName NamedDirs | Select-Object -First 1 | Should -Not -BeNullOrEmpty
    }

    It 'can construct an instance new operator' {
        [NamedDirs]::new() | Should -ExpectedType ([NamedDirs])
    }

    It 'can construct an instance with empty configuration hashtable literal' {
        [NamedDirs]@{ } | Should -ExpectedType ([NamedDirs])
    }

    It 'can construct an instance with configuration hashtable literal' {
        [NamedDirs]@{ git = "${HOME}\git"} | Should -ExpectedType ([NamedDirs])
    }

    It 'can retreive configured path' {
        $Target = "${HOME}\git"

        $NamedDirs = [NamedDirs]@{ git = $Target }

        $NamedDirs.git | Should -Be $Target
        # $NamedDirs.parse('~git')
    }

    # It 'can add a new named directory value' {
    #     $Name = "Named"
    #     $ValueRaw = $PSScriptRoot
    #     $ValueResolved = Get-Item $PSScriptRoot | Where-Object { $_ -is [DirectoryInfo]  }

    #     $NamedDirs = [NamedDirs]::new();
    #     $NamedDirs.set($Name, $ValueRaw);

    #     $NamedDirs[$Name]
    # }

}

}
