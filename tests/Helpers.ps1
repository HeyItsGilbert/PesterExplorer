function global:Get-RenderedText {
    <#
    .SYNOPSIS
    Returns the rendered text from a panel object.

    .DESCRIPTION
    This function processes a panel object to extract and return the rendered
    text. It filters out control codes and specific characters, joining the
    remaining text segments into a single string.

    .PARAMETER Panel
    The panel object to be processed. It should have a Render method that
    returns a collection of text segments.

    .PARAMETER RenderOptions
    Options to control the rendering of the panel. This is passed to the Render method of the panel.

    .PARAMETER ContainerWidth
    The width of the container in which the panel is rendered. This is also passed to the Render method of the panel.

    .EXAMPLE
    $panel = Get-PanelObject -Name "ExamplePanel"
    $renderOptions = Get-RenderOptions -SomeOption "Value"
    $containerWidth = 80
    $renderedText = global:Get-RenderedText -panel $panel -renderOptions $renderOptions -containerWidth $containerWidth

    This example retrieves a panel object, specifies rendering options and
    container width, and then calls the function to get the rendered text.
    .NOTES
    This is a helper function we can use for our tests.
    #>
    param (
        [Parameter(Mandatory = $true)]
        #[Spectre.Console.Panel]
        $Panel,
        [Parameter()]
        [int]
        $ContainerHeight = 200,
        [Parameter()]
        [int]
        $ContainerWidth = 100
    )
    $size = [Spectre.Console.Size]::new($ContainerWidth, $ContainerHeight)
    $renderOptions = [Spectre.Console.Rendering.RenderOptions]::new(
        [Spectre.Console.AnsiConsole]::Console.Profile.Capabilities,
        $size
    )
    $render = $Panel.Render($RenderOptions, $ContainerWidth)

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
