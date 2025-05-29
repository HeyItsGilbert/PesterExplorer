<center><img src="https://raw.githubusercontent.com/HeyItsGilbert/PesterExplorer/main/images/icon.png" /></center>

# PesterExplorer

A TUI to explore Pester results.

[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/PesterExplorer)](https://www.powershellgallery.com/packages/PesterExplorer/)
[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/PesterExplorer)](https://www.powershellgallery.com/packages/PesterExplorer/)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/HeyItsGilbert/PesterExplorer/CI.yaml)](https://www.powershellgallery.com/packages/PesterExplorer/)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/p/PesterExplorer)](https://www.powershellgallery.com/packages/PesterExplorer/)

## Overview

Pester does a wonderful job printing out tests results as they're running. The
difficulty can be where you're looking at a large number of results.

## Installation

> [!IMPORTANT]
> This module is for PowerShell 7. This won't work in Windows PowerShell.

```pwsh
Install-Module PesterExplorer -Scope CurrentUser
```

Installing this module will install it's dependencies which are Pester and
PwshSpectreConsole.

## Examples

To explore your result object you simply need to run `Show-PesterResult`

```pwsh
# Run Pester and make sure to PassThru the object
$pester = Invoke-Pester .\tests\ -PassThru
# Now run the TUI
Show-PesterResult $p
```

<center><img src="https://raw.githubusercontent.com/HeyItsGilbert/PesterExplorer/main/images/Show-PesterResult.png" /></center>

You can also get a tree view of your pester results with
`Show-PesterResultTree`.

```pwsh
# Run Pester and make sure to PassThru the object
$pester = Invoke-Pester .\tests\ -PassThru
# Now get that in a Tree view
Show-PesterResultTree $p
```

<center><img src="https://raw.githubusercontent.com/HeyItsGilbert/PesterExplorer/main/images/Show-PesterResultTree.png" /></center>

## Contributing

Please read the Contributors guidelines.

Make sure you bootstrap your environment by running the build command.

```pwsh
.\build.ps1 -Task Init -Bootstrap
```
