function Show-PesterResultTree {
    <#
    .SYNOPSIS
    Show a Pester result in a tree format using Spectre.Console.

    .DESCRIPTION
    This function takes a Pester result object and formats it into a tree
    structure using Spectre.Console. It is useful for visualizing the structure
    of Pester results such as runs, containers, blocks, and tests.

    .PARAMETER PesterResult
    The Pester result object to display. This should be a Pester Run object.

    .EXAMPLE
    $pesterResult = Invoke-Pester -Path "path\to\tests.ps1" -PassThru
    Show-PesterResultTree -PesterResult $pesterResult

    This example runs Pester tests and displays the results in a tree format.
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param (
        [Pester.Run]
        $PesterResult
    )
    $treeHash = Format-PesterTreeHash -Object $PesterResult
    Format-SpectreTree -Data $treeHash
}
