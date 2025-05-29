function Get-TitlePanel {
    <#
    .SYNOPSIS
    Get a title panel for the Pester Explorer.

    .DESCRIPTION
    This function generates a title panel for the Pester Explorer, displaying
    the current date and time, and optionally the name of a Pester object if
    provided. The title panel is formatted for display in a TUI (Text User
    Interface) using Spectre.Console. It returns a formatted panel that can be
    displayed in the Pester Explorer interface. If an item is provided, it
    includes the type and formatted name of the item in the title panel.

    .PARAMETER Item
    The Pester object to include in the title panel. This can be a Run,
    Container, Block, or Test object. If provided, the function will format
    the object's name and type into the title panel. If not provided, only
    the current date and time will be displayed.

    .EXAMPLE
    $titlePanel = Get-TitlePanel -Item $somePesterObject

    This example retrieves a title panel for the Pester Explorer, including
    #>
    [CmdletBinding()]
    [OutputType([Spectre.Console.Panel[]])]
    param(
        $Item
    )
    $rows = @()
    $title = "Pester Explorer - [gray]$(Get-Date)[/]"
    if($null -ne $Item){
        $objectName = Format-PesterObjectName -Object $Item
        # Print what type it is and it's formatted name.
        $title += " | $($Item.GetType().Name): $($objectName)"
    }
    $rows += $title

    return $rows | Format-SpectreRows |
        Format-SpectreAligned -HorizontalAlignment Center -VerticalAlignment Middle |
        Format-SpectrePanel -Expand
}
