<center><img src="https://raw.githubusercontent.com/HeyItsGilbert/PesterExplorer/main/images/icon.png" width="120px" /></center>

# PesterExplorer

A TUI to explore Pester results.

## Overview

Pester does a wonderful job printing out tests results as they're running. The
difficulty can be where you're looking at a large number of results.

## Installation

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

![](images\Show-PesterResult.png)

You can also get a tree view of your pester results with
`Show-PesterResultTree`.

```pwsh
# Run Pester and make sure to PassThru the object
$pester = Invoke-Pester .\tests\ -PassThru
# Now get that in a Tree view
Show-PesterResultTree $p
```

![](images\Show-PesterResultTree.png)

## Contributing

Please read the Contributors guidelines.

Make sure you bootstrap your environment by running the build command.

```pwsh
.\build.ps1 -Task Init -Bootstrap
```
