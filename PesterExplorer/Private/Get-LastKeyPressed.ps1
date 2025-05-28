function Get-LastKeyPressed {
    <#
    .SYNOPSIS
    Get the last key pressed in the console.

    .DESCRIPTION
    This function checks if any key has been pressed in the console and returns
    the last key pressed. It is useful for handling user input in a TUI (Text
    User Interface) environment.

    .EXAMPLE
    $key = Get-LastKeyPressed
    if ($key -eq "Enter") {
        # Make the TUI do something
    }

    This example retrieves the last key pressed and checks if it was the Enter
    key.

    .NOTES
    This function is meant to be used in a TUI context where you need to
    handle user input. It reads the console key buffer and returns the last key
    pressed without displaying it on the console.
    #>
    [CmdletBinding()]
    [OutputType([ConsoleKeyInfo])]
    param ()
    $lastKeyPressed = $null
    while ([Console]::KeyAvailable) {
        $lastKeyPressed = [Console]::ReadKey($true)
    }
    return $lastKeyPressed
}
