# spell-checker:ignore Renderable
function Get-PreviewPanel {
    <#
    .SYNOPSIS
    Get a preview panel for a selected Pester object.

    .DESCRIPTION
    This function generates a preview panel for a selected Pester object, such
    as a Run, Container, Block, or Test. It formats the object and its results
    into a structured output suitable for display in a TUI (Text User
    Interface). The function handles different types of Pester objects and
    extracts relevant information such as test results, standard output, and
    error records. The output is formatted into a grid and panel for better
    readability. The function returns a formatted panel that can be displayed in
    a TUI environment. If no item is selected, it prompts the user to select an
    item. If the selected item is a Test, it shows the test result and the code
    tested. If the selected item is a Run, Container, or Block, it shows the
    results in a tree structure. It also displays standard output and errors if
    they exist. The function is designed to be used in a Pester Explorer
    context, where users can explore and preview Pester test results in a
    structured and user-friendly manner.

    .PARAMETER Items
    A hashtable containing Pester objects (Run, Container, Block, Test) to be
    displayed in the preview panel.

    .PARAMETER SelectedItem
    The key of the selected item in the Items hashtable. This can be a Pester
    object such as a Run, Container, Block, or Test.

    .EXAMPLE
    $run = Invoke-Pester -Path 'tests' -PassThru
    $items = Get-ListFromObject -Object $run
    $selectedItem = 'Test1'
    Get-PreviewPanel -Items $items -SelectedItem $selectedItem

    This example retrieves a Pester run object, formats it into a list of items,
    and generates a preview panel for the selected item 'Test1'.

    .NOTES
    This function is part of the Pester Explorer module and is used to display
    Pester test results in a TUI. It formats the output using Spectre.Console
    and provides a structured view of the Pester objects. The function handles
    different types of Pester objects and extracts relevant information for
    display. It is designed to be used in a Pester Explorer context, where users
    can explore and preview Pester test results in a structured and
    user-friendly manner.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [hashtable]
        $Items,
        [Parameter(Mandatory)]
        [string]
        $SelectedItem,
        $ScrollPosition = 0,
        [Parameter()]
        [ValidateNotNull()]
        $PreviewHeight,
        [Parameter()]
        [ValidateNotNull()]
        $PreviewWidth,
        [string]$SelectedPane = "list"
    )
    Write-Debug "Get-PreviewPanel called with SelectedItem: $SelectedItem, ScrollPosition: $ScrollPosition"
    $paneColor = if($SelectedPane -ne "preview") {
        # If the selected pane is not preview, return an empty panel
        "blue"
    } else {
        "white"
    }
    if($SelectedItem -like "*..") {
        $formatSpectreAlignedSplat = @{
            HorizontalAlignment = 'Center'
            VerticalAlignment = 'Middle'
        }
        return "[grey]Please select an item.[/]" |
            Format-SpectreAligned @formatSpectreAlignedSplat |
            Format-SpectrePanel -Header "[white]Preview[/]" -Expand -Color $paneColor
    }
    $object = $Items.Item($SelectedItem)
    $results = @()
    # SelectedItem can be a few different types:
    # - A Pester object (Run, Container, Block, Test)

    #region Breakdown
    # Skip if the object is null or they are all zero.
    if (
        $null -ne $object.PassedCount -and
        $null -ne $object.InconclusiveCount -and
        $null -ne $object.SkippedCount -and
        $null -ne $object.FailedCount -and
        (
            [int]$object.PassedCount +
            [int]$object.InconclusiveCount +
            [int]$object.SkippedCount +
            [int]$object.FailedCount
        ) -gt 0
    ) {
        Write-Debug "Adding breakdown chart for $($object.Name)"
        $data = @()
        $data += New-SpectreChartItem -Label "Passed" -Value ($object.PassedCount) -Color "Green"
        $data += New-SpectreChartItem -Label "Failed" -Value ($object.FailedCount) -Color "Red"
        $data += New-SpectreChartItem -Label "Inconclusive" -Value ($object.InconclusiveCount) -Color "Grey"
        $data += New-SpectreChartItem -Label "Skipped" -Value ($object.SkippedCount) -Color "Yellow"
        $results += Format-SpectreBreakdownChart -Data $data
    }
    #endregion Breakdown

    # For Tests Let's print some more details
    if ($object.GetType().Name -eq "Test") {
        Write-Debug "Selected item is a Test: $($object.Name)"
        $formatSpectrePanelSplat = @{
            Header = "Test Result"
            Border = "Rounded"
            Color = "White"
        }
        $results += $object.Result |
            Format-SpectrePanel @formatSpectrePanelSplat
        # Show the code tested
        $formatSpectrePanelSplat = @{
            Header = "Test Code"
            Border = "Rounded"
            Color = "White"
        }
        $results += $object.ScriptBlock |
            Get-SpectreEscapedText |
            Format-SpectrePanel @formatSpectrePanelSplat
    } else {
        Write-Debug "Selected item '$($object.Name)'is a Pester object: $($object.GetType().Name)"
        $data = Format-PesterTreeHash -Object $object
        Write-Debug $($data|ConvertTo-Json -Depth 10)
        $formatSpectrePanelSplat = @{
            Header = "Results"
            Border = "Rounded"
            Color = "White"
        }
        $results += Format-SpectreTree -Data $data |
            Format-SpectrePanel @formatSpectrePanelSplat
    }

    if($null -ne $object.StandardOutput){
        Write-Debug "Adding standard output for $($object.Name)"
        $formatSpectrePanelSplat = @{
            Header = "Standard Output"
            Border = "Ascii"
            Color = "White"
        }
        $results += $object.StandardOutput |
            Get-SpectreEscapedText |
            Format-SpectrePanel @formatSpectrePanelSplat
    }

    # Print errors if they exist.
    if($object.ErrorRecord.Count -gt 0) {
        Write-Debug "Adding error records for $($object.Name)"
        $errorRecords = @()
        $object.ErrorRecord | ForEach-Object {
            $errorRecords += $_ |
                Format-SpectreException -ExceptionFormat ShortenEverything
        }
        $results += $errorRecords | Format-SpectreRows | Format-SpectrePanel -Header "Errors" -Border "Rounded" -Color "Red"
    }

    $formatSpectrePanelSplat = @{
        Header = "[white]Preview[/]"
        Color = $paneColor
        Height = $PreviewHeight
        Width = $PreviewWidth
        Expand = $true
    }

    if($scrollPosition -ge $results.Count) {
        # If the scroll position is greater than the number of items,
        # reset it to the last item
        Write-Debug "Resetting ScrollPosition to last item."
        $scrollPosition = $results.Count - 1
    }
    # If the scroll position is out of bounds, reset it
    if ($scrollPosition -lt 0) {
        Write-Debug "Resetting ScrollPosition to 0."
        $scrollPosition = 0
    }

    if($results.Count -eq 0) {
        # If there are no results, return an empty panel
        return "[grey]No results to display.[/]" |
            Format-SpectreAligned -HorizontalAlignment Center -VerticalAlignment Middle |
            Format-SpectrePanel @formatSpectrePanelSplat
    } else {
        Write-Debug "Reducing Preview List: $($results.Count), ScrollPosition: $scrollPosition"

        # Determine the height of each item in the results
        $totalHeight = 3
        $reducedList = @()
        if($ScrollPosition -ne 0) {
            # If the scroll position is not zero, add a "back" item
            $reducedList += "[grey]...[/]"
        }
        for ($i = $scrollPosition; $i -lt $results.Count; $i++) {
            $itemHeight = Get-SpectreRenderableSize $results[$i]
            $totalHeight += $itemHeight.Height
            if ($totalHeight -gt $PreviewHeight) {
                if($i -eq $scrollPosition) {
                    # If the first item already exceeds the height, stop here
                    Write-Debug "First item exceeds preview height. Stopping. Total Height: $totalHeight, Preview Height: $PreviewHeight"
                    $reducedList += ":police_car_light:The next item is too large to display! Please resize your terminal.:police_car_light:" |
                        Format-SpectreAligned -HorizontalAlignment Center -VerticalAlignment Middle |
                        Format-SpectrePanel -Header ":police_car_light: [red]Warning[/]" -Color 'red' -Border Double
                    break
                }
                # If the total height exceeds the preview height, stop adding items
                Write-Debug "Total height exceeded preview height. Stopping at item $i."
                $reducedList += "[blue]...more. Switch to Panel and scroll with keys.[/]"
                break
            }
            $reducedList += $results[$i]
        }
    }

    return $reducedList | Format-SpectreRows |
        Format-SpectrePanel @formatSpectrePanelSplat
        #Format-ScrollableSpectrePanel @formatScrollableSpectrePanelSplat
}
