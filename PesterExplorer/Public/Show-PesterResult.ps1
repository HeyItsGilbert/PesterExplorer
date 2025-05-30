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
        [Parameter(Mandatory = $true)]
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
        $selectedPane = 'list'
        $scrollPosition = 0
        #endregion Initial State

        while ($true) {
            # Check the layout sizes
            $sizes = $layout | Get-SpectreLayoutSizes
            $previewHeight = $sizes["preview"].Height
            $previewWidth = $sizes["preview"].Width
            Write-Debug "Preview size: $previewWidth x $previewHeight"

            # Handle input
            $lastKeyPressed = Get-LastKeyPressed
            if ($null -ne $lastKeyPressed) {
                #region List Navigation
                if($selectedPane -eq 'list') {
                    if ($lastKeyPressed.Key -in @("j", "DownArrow")) {
                        $selectedItem = $list[($list.IndexOf($selectedItem) + 1) % $list.Count]
                        $scrollPosition = 0
                    } elseif ($lastKeyPressed.Key -in @("k", "UpArrow")) {
                        $selectedItem = $list[($list.IndexOf($selectedItem) - 1 + $list.Count) % $list.Count]
                        $scrollPosition = 0
                    } elseif ($lastKeyPressed.Key -eq "PageDown") {
                        $currentIndex = $list.IndexOf($selectedItem)
                        $newIndex = [Math]::Min($currentIndex + 10, $list.Count - 1)
                        $selectedItem = $list[$newIndex]
                        $scrollPosition = 0
                    } elseif ($lastKeyPressed.Key -eq "PageUp") {
                        $currentIndex = $list.IndexOf($selectedItem)
                        $newIndex = [Math]::Max($currentIndex - 10, $list.Count - 1)
                        $selectedItem = $list[$newIndex]
                        $scrollPosition = 0
                    } elseif ($lastKeyPressed.Key -eq "Home") {
                        $selectedItem = $list[0]
                        $scrollPosition = 0
                    } elseif ($lastKeyPressed.Key -eq "End") {
                        $selectedItem = $list[-1]
                        $scrollPosition = 0
                    } elseif ($lastKeyPressed.Key -in @("Tab", "RightArrow", "l")) {
                        $selectedPane = 'preview'
                    } elseif ($lastKeyPressed.Key -eq "Enter") {
                        <# Recurse into Pester Object #>
                        if($items.Item($selectedItem).GetType().Name -eq "Test") {
                            # This is a test. We don't want to go deeper.
                        }
                        if($selectedItem -like '*..*') {
                            # Move up one via selecting ..
                            $object = $stack.Pop()
                            Write-Debug "Popped item from stack: $($object.Name)"
                        } else {
                            Write-Debug "Pushing item into stack: $($items.Item($selectedItem).Name)"
                            $stack.Push($object)
                            $object = $items.Item($selectedItem)
                        }
                        $items = Get-ListFromObject -Object $object
                        $list = [array]$items.Keys
                        $selectedItem = $list[0]
                        $scrollPosition = 0
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
                        $scrollPosition = 0
                    }
                }
                else {
                    #region Preview Navigation
                    if ($lastKeyPressed.Key -in "Escape", "Tab", "LeftArrow", "h") {
                        $selectedPane = 'list'
                    } elseif ($lastKeyPressed.Key -eq "Down") {
                        # Scroll down in the preview panel
                        $scrollPosition = $ScrollPosition + 1
                    } elseif ($lastKeyPressed.Key -eq "Up") {
                        # Scroll up in the preview panel
                        $scrollPosition = $ScrollPosition - 1
                    } elseif ($lastKeyPressed.Key -eq "PageDown") {
                        # Scroll down by a page in the preview panel
                        $scrollPosition = $ScrollPosition + 1
                    } elseif ($lastKeyPressed.Key -eq "PageUp") {
                        # Scroll up by a page in the preview panel
                        $scrollPosition = $ScrollPosition - 1
                    }
                    #endregion Preview Navigation
                }
            }

            # Generate new data
            $titlePanel = Get-TitlePanel -Item $object
            $getListPanelSplat = @{
                List = $list
                SelectedItem = $selectedItem
                SelectedPane = $selectedPane
            }
            $listPanel = Get-ListPanel @getListPanelSplat

            $getPreviewPanelSplat = @{
                Items = $items
                SelectedItem = $selectedItem
                ScrollPosition = $scrollPosition
                PreviewHeight = $previewHeight
                PreviewWidth = $previewWidth
                SelectedPane = $selectedPane
            }
            $previewPanel = Get-PreviewPanel @getPreviewPanelSplat

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
