function Show-PesterResult {
    <#
    .SYNOPSIS
    Open a TUI to explore the Pester result object.

    .DESCRIPTION
    Show a Pester result in a TUI (Text User Interface) using Spectre.Console.
    This function builds a layout with a header, a list of items, and a preview panel.

    .PARAMETER PesterResult
    The Pester result object to display. This should be a Pester Run object.

    .PARAMETER NoShortcutPanel
    If specified, the shortcut panel will not be displayed at the bottom of the TUI.

    .EXAMPLE
    $pesterResult = Invoke-Pester -Path "path\to\tests.ps1" -PassThru
    Show-PesterResult -PesterResult $pesterResult

    This example runs Pester tests and opens a TUI to explore the results.
    #>
    [CmdletBinding()]
    [OutputType([void])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSReviewUnusedParameter',
        'PesterResult',
        Justification='This is actually used in the script block.'
    )]
    param (
        [ValidateNotNullOrEmpty()]
        [Pester.Run]
        $PesterResult,
        [switch]
        $NoShortcutPanel
    )
    # Build and show the TUI
    $rows = @(
        # Row 1
        (
            New-SpectreLayout -Name "header" -MinimumSize 5 -Ratio 1 -Data ("empty")
        ),
        # Row 2
        (
            New-SpectreLayout -Name "content" -Ratio 10 -Columns @(
                (
                    New-SpectreLayout -Name "list" -Ratio 1 -Data "empty"
                ),
                (
                    New-SpectreLayout -Name "preview" -Ratio 4 -Data "empty"
                )
            )
        )
    )
    if(-not $NoShortcutPanel) {
        $rows += (
            # Row 3
            (
                New-SpectreLayout -Name "footer" -Ratio 1 -MinimumSize 1 -Data (
                    Get-ShortcutKeyPanel
                )
            )
        )
    }
    $layout = New-SpectreLayout -Name "root" -Rows $rows

    # Start live rendering the layout
    Invoke-SpectreLive -Data $layout -ScriptBlock {
        param (
            [Spectre.Console.LiveDisplayContext] $Context
        )

        #region Initial State
        $items = Get-ListFromObject -Object $PesterResult
        Write-Debug "Items: $($items.Keys -join ', ')"
        $list = [array]$items.Keys
        $selectedItem = $list[0]
        $stack = [System.Collections.Stack]::new()
        $object = $PesterResult
        #endregion Initial State

        while ($true) {
            # Handle input
            $lastKeyPressed = Get-LastKeyPressed
            # ToDo: Add support for scrolling the right panel
            if ($null -ne $lastKeyPressed) {
                if ($lastKeyPressed.Key -eq "DownArrow") {
                    $selectedItem = $list[($list.IndexOf($selectedItem) + 1) % $list.Count]
                } elseif ($lastKeyPressed.Key -eq "UpArrow") {
                    $selectedItem = $list[($list.IndexOf($selectedItem) - 1 + $list.Count) % $list.Count]
                } elseif ($lastKeyPressed.Key -eq "Enter") {
                    <# Recurse into Pester Object #>
                    if($selectedItem -like '*..*') {
                        # Move up one via selecting ..
                        $object = $stack.Pop()
                        Write-Debug "Popped item from stack: $($object.Name)"
                    } else {
                        Write-Debug "Pushing item into stack: $($items.Item($selectedItem).Name)"

                        $stack.Push($object)
                        $object = $items.Item($selectedItem)
                        if($object.GetType().Name -eq "Test") {
                            # This is a test. We don't want to go deeper.
                            $object = $stack.Pop()
                        }
                    }
                    $items = Get-ListFromObject -Object $object
                    $list = [array]$items.Keys
                    $selectedItem = $list[0]
                } elseif ($lastKeyPressed.Key -eq "Escape") {
                    # Move up via Esc key
                    if($stack.Count -eq 0) {
                        # This is the top level. Exit the loop.
                        return
                    }
                    $object = $stack.Pop()
                    $items = Get-ListFromObject -Object $object
                    $list = [array]$items.Keys
                    $selectedItem = $list[0]
                }
            }

            # Generate new data
            $titlePanel = Get-TitlePanel -Item $object
            $panelSplat = @{
                List = $list
                SelectedItem = $selectedItem
            }
            $listPanel = Get-ListPanel @panelSplat
            $previewPanel = Get-PreviewPanel @panelSplat

            # Update layout
            $layout["header"].Update($titlePanel) | Out-Null
            $layout["list"].Update($listPanel) | Out-Null
            $layout["preview"].Update($previewPanel) | Out-Null

            # Draw changes
            $Context.Refresh()
            Start-Sleep -Milliseconds 100
        }
    }
}
