# PSNamedDirs

Powershell module implementing [z-shell style named directories](https://sorrell.github.io/2020/03/16/WSL-and-ZSH.html) (to the extent possible in a module).

``` powershell
# zsh Command
cd ~git/repo

# Equivalent (unaliased)
Set-NamedLocation ~git/repo
```

## Configuration (Changes Expected)

``` powershell
$global:PSNamedDirs

# Key     Value
# ---     -----
# dot     C:\Users\User\dotfile
# dotfile C:\Users\User\dotfile
# pwsh    C:\Users\User\dotfile\pwsh
# gl      C:\Users\User\git.local
# git     C:\Users\User\git
```

## Completions (Work in Progress)

``` powershell
Set-NamedLocation ~g|->
# ~g ~git ~gitlocal ~gl

Set-NamedLocation ~git/r|->
# ~git/repo1 ~git/repo2 ~git/repo3 ~git/repo4
```
