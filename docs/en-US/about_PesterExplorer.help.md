# PesterExplorer

## about_PesterExplorer

# SHORT DESCRIPTION

A TUI to explore Pester results.

# LONG DESCRIPTION

A TUI built on top of PwshSpectreConsole to navigate and see your Pester run
results.

# EXAMPLES

To explore your result object you simply need to run `Show-PesterResult`

```pwsh
# Run Pester and make sure to PassThru the object
$pester = Invoke-Pester .\tests\ -PassThru
# Now run the TUI
Show-PesterResult $p
```

You can also get a tree view of your pester results with
`Show-PesterResultTree`.

```pwsh
# Run Pester and make sure to PassThru the object
$pester = Invoke-Pester .\tests\ -PassThru
# Now get that in a Tree view
Show-PesterResultTree $p
```

# NOTE

This only works in PowerShell 7 because PwshSpectreConsole is only for 7.

# TROUBLESHOOTING NOTE

Make sure your Pester Results are passed back with the `-PassThru` parameter.

# SEE ALSO

- [Pester](pester.dev)
- [PwshSpectreConsole](pwshspectreconsole.com)

# KEYWORDS

- Pester
- TDD
- TUI
