function Show-PesterResultTree {
    [CmdletBinding()]
    [OutputType([void])]
    param (
        [Pester.Run]
        $PesterResult
    )
    $treeHash = Format-PesterTreeHash -Object $PesterResult
    Format-SpectreTree -Data $treeHash
}
