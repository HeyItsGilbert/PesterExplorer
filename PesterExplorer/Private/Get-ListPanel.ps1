function Get-ListPanel {
    <#
    .SYNOPSIS
    Create a list panel for displaying items in a TUI.

    .DESCRIPTION
    This function generates a list panel that displays items in a TUI (Text User
    Interface) using Spectre.Console. It formats the items based on whether they
    are selected or not, and handles special cases like parent directories.
    
    The function supports viewport management, showing only a subset of items
    when the list is longer than the available display height.

    .PARAMETER List
    An array of strings to display in the list. Each item can be a file path,
    a test name, or a special item like '..' for parent directories.

    .PARAMETER SelectedItem
    The item that is currently selected in the list. This will be highlighted
    differently from unselected items.

    .PARAMETER SelectedPane
    Indicates which pane is currently selected. Affects the border color of the panel.

    .PARAMETER ListScrollPosition
    The scroll position within the list. Used for viewport management when the list
    is longer than the available display height.

    .PARAMETER ListHeight
    The height of the list display area. When specified and the list is longer,
    viewport management is applied to show only visible items.

    .EXAMPLE
    Get-ListPanel -List @('file1.txt', 'file2.txt', '..') -SelectedItem 'file1.txt'

    This example creates a list panel with three items, highlighting 'file1.txt'
    as the selected item.

    .EXAMPLE
    Get-ListPanel -List $longList -SelectedItem 'item5' -ListScrollPosition 2 -ListHeight 10

    This example creates a list panel with viewport management, starting from scroll
    position 2 and displaying up to 10 items.

    .NOTES
    This is meant to be called by the main TUI function: Show-PesterResult
    #>
    [CmdletBinding()]
    param (
        [array]
        $List,
        [string]
        $SelectedItem,
        [string]$SelectedPane = "list",
        [int]$ListScrollPosition = 0,
        [int]$ListHeight = 0
    )
    $paneColor = if($SelectedPane -ne "list") {
        # If the selected pane is not preview, return an empty panel
        "blue"
    } else {
        "white"
    }
    $unselectedStyle = @{
        RootColor      = [Spectre.Console.Color]::Grey
        SeparatorColor = [Spectre.Console.Color]::Grey
        StemColor      = [Spectre.Console.Color]::Grey
        LeafColor      = [Spectre.Console.Color]::White
    }
    $results = $List | ForEach-Object {
        $name = $_
        if($name -eq '..') {
            # This is a parent item, so we show it as a folder
            if ($name -eq $SelectedItem) {
                Write-SpectreHost ":up_arrow: [Turquoise2]$name[/]" -PassThru |
                    Format-SpectrePadded -Padding 1
            } else {
                Write-SpectreHost "$name" -PassThru |
                    Format-SpectrePadded -Padding 0
            }
        }
        elseif(Test-Path $name){
            $relativePath = [System.IO.Path]::GetRelativePath(
                (Get-Location).Path,
                $name
            )
            if ($name -eq $SelectedItem) {
                Format-SpectreTextPath -Path $relativePath |
                    Format-SpectrePadded -Padding 1
            } else {
                $formatSpectreTextPathSplat = @{
                    Path = $relativePath
                    PathStyle = $unselectedStyle
                }
                Format-SpectreTextPath @formatSpectreTextPathSplat |
                    Format-SpectrePadded -Padding 0
            }
        }
        else {
            if ($name -eq $SelectedItem) {
                $writeSpectreHostSplat = @{
                    PassThru = $true
                    Message = ":right_arrow: [Turquoise2]$name[/]"
                }
                Write-SpectreHost @writeSpectreHostSplat |
                    Format-SpectrePadded -Padding 1
            } else {
                Write-SpectreHost $name -PassThru |
                    Format-SpectrePadded -Padding 0
            }
        }
    }

    # Apply viewport scrolling if list height is specified and list is long
    if ($ListHeight -gt 0 -and $List.Count -gt $ListHeight) {
        Write-Debug "Applying list viewport scrolling. List count: $($List.Count), Height: $ListHeight, Scroll: $ListScrollPosition"
        
        # Calculate which items to show based on scroll position and height
        $visibleResults = @()
        
        # Add scroll indicator if not at top
        if ($ListScrollPosition -gt 0) {
            $visibleResults += "[grey]...[/]" | Write-SpectreHost -PassThru | Format-SpectrePadded -Padding 0
        }
        
        # Calculate available height (subtract 1 if we added scroll indicator)
        $availableHeight = $ListHeight
        if ($ListScrollPosition -gt 0) {
            $availableHeight--
        }
        
        # Add items starting from scroll position
        $itemsAdded = 0
        for ($i = $ListScrollPosition; $i -lt $results.Count -and $itemsAdded -lt $availableHeight; $i++) {
            $visibleResults += $results[$i]
            $itemsAdded++
        }
        
        # Add more indicator if there are more items below
        if (($ListScrollPosition + $itemsAdded) -lt $results.Count) {
            if ($itemsAdded -eq $availableHeight) {
                # Replace last item with more indicator if we're at max height
                $visibleResults[-1] = "[grey]...more[/]" | Write-SpectreHost -PassThru | Format-SpectrePadded -Padding 0
            } else {
                # Add more indicator if there's space
                $visibleResults += "[grey]...more[/]" | Write-SpectreHost -PassThru | Format-SpectrePadded -Padding 0
            }
        }
        
        $results = $visibleResults
    }
    
    $results |
        Format-SpectreRows |
        Format-SpectrePanel -Header "[white]List[/]" -Expand -Color $paneColor
}
