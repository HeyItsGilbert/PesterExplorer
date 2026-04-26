function Get-ListPanel {
    <#
    .SYNOPSIS
    Create a list panel for displaying items in a TUI.

    .DESCRIPTION
    This function generates a list panel that displays items in a TUI (Text User
    Interface) using Spectre.Console. It formats the items based on whether they
    are selected or not, and handles special cases like parent directories.

    .PARAMETER List
    An array of strings to display in the list. Each item can be a file path,
    a test name, or a special item like '..' for parent directories.

    .PARAMETER SelectedItem
    The item that is currently selected in the list. This will be highlighted
    differently from unselected items.

    .EXAMPLE
    Get-ListPanel -List @('file1.txt', 'file2.txt', '..') -SelectedItem 'file1.txt'

    This example creates a list panel with three items, highlighting 'file1.txt'
    as the selected item.
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
        [int]$ScrollOffset = 0,
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
    # Calculate the visible window. Panel borders and potential ellipsis rows consume 4 rows.
    $visibleCount = if ($ListHeight -gt 4) { $ListHeight - 4 } else { $List.Count }
    $startIndex = [Math]::Max(0, [Math]::Min($ScrollOffset, $List.Count - 1))
    $endIndex = [Math]::Min($startIndex + $visibleCount - 1, $List.Count - 1)
    $showEllipsisTop = $startIndex -gt 0
    $showEllipsisBottom = $endIndex -lt ($List.Count - 1)
    $visibleList = if ($List.Count -gt 0) { @($List[$startIndex..$endIndex]) } else { @() }

    $results = @()
    if ($showEllipsisTop) {
        $results += Write-SpectreHost "[grey]...[/]" -PassThru | Format-SpectrePadded -Padding 0
    }
    $results += $visibleList | ForEach-Object {
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
    if ($showEllipsisBottom) {
        $results += Write-SpectreHost "[grey]...[/]" -PassThru | Format-SpectrePadded -Padding 0
    }
    $results |
        Format-SpectreRows |
        Format-SpectrePanel -Header "[white]List[/]" -Expand -Color $paneColor
}
