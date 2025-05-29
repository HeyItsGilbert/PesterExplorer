function Get-ShortcutKeyPanel {
    <#
    .SYNOPSIS
    Get a panel displaying shortcut keys for the Pester Explorer TUI.

    .DESCRIPTION
    This function generates a panel that displays the shortcut keys available
    in the Pester Explorer TUI. The keys are formatted for display using
    Spectre.Console, providing a user-friendly interface for navigating the
    Pester Explorer. The panel includes common shortcuts for navigation,
    exploration, and exiting the TUI. It returns a formatted panel that can be
    displayed in the Pester Explorer interface.

    .EXAMPLE
    $shortcutPanel = Get-ShortcutKeyPanel

    This example retrieves a panel displaying the shortcut keys for the Pester
    Explorer TUI. The panel includes keys for navigation, exploration, and
    exiting the TUI, formatted for easy readability.
    #>
    [CmdletBinding()]
    $shortcutKeys = @(
        "Up, Down - Navigate",
        "Home, End - Jump to Top/Bottom",
        "PageUp, PageDown - Scroll",
        "Enter - Explore",
        "Tab - Switch Panel",
        "Esc - Back",
        "Ctrl+C - Exit"
    )
    $formatSpectreAlignedSplat = @{
        HorizontalAlignment = 'Center'
        VerticalAlignment = 'Middle'
    }
    $result = $shortcutKeys | Foreach-Object {
        "[grey]$($_)[/]"
    } | Format-SpectreColumns -Padding 5 |
        Format-SpectreAligned @formatSpectreAlignedSplat |
        Format-SpectrePanel -Expand -Border 'None'
    return $result
}
