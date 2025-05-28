function Get-ShortcutKeyPanel {
    [CmdletBinding()]
    $shortcutKeys = @(
        "Up, Down - Navigate",
        "Enter - Explore",
        "Esc - Back",
        "Ctrl+C - Exit"
        # TODO: Add a key to jump to the test
    )
    $result = $shortcutKeys | Foreach-Object {
        "[grey]$($_)[/]"
    } | Format-SpectreColumns -Padding 5 |
        Format-SpectreAligned -HorizontalAlignment Center -VerticalAlignment Middle |
        Format-SpectrePanel -Expand -Border 'None'
    return $result
}
