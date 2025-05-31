
function global:Get-RenderedText {
    param (
        $panel,
        $renderOptions,
        $containerWidth
    )
    $render = $panel.Render($renderOptions, $ContainerWidth)

    # These are rendered segments.
    $onlyText = $render |
        Where-Object {
            #$_.IsLineBreak -ne $true -and
            $_.IsControlCode -ne $true -and
            #$_.IsWhiteSpace -ne $true -and
            $_.Text -notin @('┌', '┐', '└', '┘', '─', '│') -and
            $_.Text -notmatch '─{2,}'
        }
    # Join the text segments into a single string
    $output = [System.Text.StringBuilder]::new()

    foreach ($textSegment in $onlyText) {
        if ($textSegment.IsLineBreak) {
            [void]$output.AppendLine() # Append a newline for line breaks
        } else {
            [void]$output.Append($textSegment.Text)
        }
    }
    return $output.ToString().Trim()
}
