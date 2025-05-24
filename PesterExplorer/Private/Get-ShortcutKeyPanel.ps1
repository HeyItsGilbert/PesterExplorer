function Get-ShortcutKeyPanel {
    $shortcutKeys = @(
        "Up, Down - Navigate",
        "Enter - Explore",
        "Esc - Exit",
        "Ctrl+C - Exit"
    )
    $result = $shortcutKeys | Foreach-Object {
        "[grey]$($_)[/]"
    } | Format-SpectreColumns -Padding 5 |
        Format-SpectreAligned -HorizontalAlignment Center -VerticalAlignment Middle |
        Format-SpectrePanel -Expand -Border 'None'
    return $result
}
