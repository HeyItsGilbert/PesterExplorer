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
        [hashtable]
        $Items,
        [string]
        $SelectedItem
    )
    if($SelectedItem -like "*..") {
        $formatSpectreAlignedSplat = @{
            HorizontalAlignment = 'Center'
            VerticalAlignment = 'Middle'
        }
        return "[grey]Please select an item.[/]" |
            Format-SpectreAligned @formatSpectreAlignedSplat |
            Format-SpectrePanel -Header "[white]Preview[/]" -Expand
    }
    $object = $Items.Item($SelectedItem)
    $result = @()
    # SelectedItem can be a few different types:
    # - A Pester object (Run, Container, Block, Test)

    #region Breakdown
    # Skip if the object is null or they are all zero.
    if (
        (
            $object.PassedCount +
            $object.InconclusiveCount +
            $object.SkippedCount +
            $object.FailedCount
        ) -gt 0
    ) {
        $data = @()
        $data += New-SpectreChartItem -Label "Passed" -Value ($object.PassedCount) -Color "Green"
        $data += New-SpectreChartItem -Label "Failed" -Value ($object.FailedCount) -Color "Red"
        $data += New-SpectreChartItem -Label "Inconclusive" -Value ($object.InconclusiveCount) -Color "Grey"
        $data += New-SpectreChartItem -Label "Skipped" -Value ($object.SkippedCount) -Color "Yellow"
        $result += Format-SpectreBreakdownChart -Data $data
    }
    #endregion Breakdown

    # For Tests Let's print some more details
    if ($object.GetType().Name -eq "Test") {
        $formatSpectrePanelSplat = @{
            Header = "Test Result"
            Border = "Rounded"
            Color = "White"
        }
        $result += $object.Result |
            Format-SpectrePanel @formatSpectrePanelSplat
        # Show the code tested
        $formatSpectrePanelSplat = @{
            Header = "Test Code"
            Border = "Rounded"
            Color = "White"
        }
        $result += $object.ScriptBlock |
            Get-SpectreEscapedText |
            Format-SpectrePanel @formatSpectrePanelSplat
    } else {
        $data = Format-PesterTreeHash -Object $object
        Write-Debug $($data|ConvertTo-Json -Depth 10)
        $formatSpectrePanelSplat = @{
            Header = "Results"
            Border = "Rounded"
            Color = "White"
        }
        $result += Format-SpectreTree -Data $data |
            Format-SpectrePanel @formatSpectrePanelSplat
    }

    if($null -ne $object.StandardOutput){
        $formatSpectrePanelSplat = @{
            Header = "Standard Output"
            Border = "Ascii"
            Color = "White"
        }
        $result += $object.StandardOutput |
            Get-SpectreEscapedText |
            Format-SpectrePanel @formatSpectrePanelSplat

    }

    # Print errors if they exist.
    if($object.ErrorRecord.Count -gt 0) {
        $errorRecords = @()
        $object.ErrorRecord | ForEach-Object {
            $errorRecords += $_ |
                Format-SpectreException -ExceptionFormat ShortenEverything
        }
        $formatSpectrePanelSplat = @{
            Header = "Errors"
            Border = "Rounded"
            Color = "Red"
        }
        $result += $errorRecords |
            Format-SpectreRows |
            Format-SpectrePanel @formatSpectrePanelSplat
    }

    return $result |
        Format-SpectreGrid |
        Format-SpectrePanel -Header "[white]Preview[/]" -Expand
}
