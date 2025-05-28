---
mode: 'ask'
---
This project uses PwshSpectreConsole and Pester to render a TUI for Pester
results.The TUI allows users to navigate through Pester run results, viewing
details of containers, blocks, and tests.

All suggestions should try to stay with 80 characters or 120 max. Use splatting
when possible. You can create new lines after `|` to make it more readable.

# Examples
You can use the following when you create `.EXAMPLE` text for the comment based
help. All Object parameters will use the $run variable from the following code:

```
$run = Invoke-Pester -Path 'tests' -PassThru
```

# Example 1
```powershell
$run = Invoke-Pester -Path 'tests' -PassThru
$run | Show-PesterResults
```

An explanation of the example should be provided in the `.EXAMPLE` section with
an empty line between the example and the explanation.

# PowerShell Functions
All functions should have a `[CmdletBinding()]` attribute.
