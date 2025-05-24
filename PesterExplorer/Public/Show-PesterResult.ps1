function Show-PesterResult {
    [CmdletBinding()]
    [OutputType([void])]
    param (
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
    # Type "↓", "↓", "↓" to navigate the file list, and press "Enter" to explore
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
        $stack.Push($PesterResult)
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
                    if($items.Item($selectedItem).GetType().Name -eq "Test") {
                        # This is a test. We don't want to go deeper.
                    }
                    if($selectedItem -like '*..') {
                        # Move up one via selecting ..
                        $object = $stack.Pop()
                        Write-Debug "Popped item from stack: $($object.Name)"
                    } else {
                        Write-Debug "Pushing item into stack: $($items.Item($selectedItem).Name)"
                        $stack.Push($items.Item($selectedItem))
                        $object = $items.Item($selectedItem)
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
            $listPanel = Get-ListPanel -List $list -SelectedItem $selectedItem
            $previewPanel = Get-PreviewPanel -Items $items -SelectedItem $selectedItem

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
