function Get-PreviewPanel {
    param (
        [hashtable]
        $Items,
        [string]
        $SelectedItem
    )
    if($SelectedItem -like "*..") {
        return "[grey]Please select an item.[/]" | Format-SpectreAligned -HorizontalAlignment Center -VerticalAlignment Middle | Format-SpectrePanel -Header "[white]Preview[/]" -Expand
    }
    $object = $Items.Item($SelectedItem)
    $result = @()
    # SelectedItem can be a few different types:
    # - A Pester object (Run, Container, Block, Test)

    # For Tests Let's print some more details
    if ($object.GetType().Name -eq "Test") {
        $result += $object.Result | Format-SpectrePanel -Header "Test Result" -Border "Rounded" -Color "White"
    } else {
        $data = Format-PesterTreeHash -Object $object
        Write-Debug $($data|ConvertTo-Json -Depth 10)
        $result += Format-SpectreTree -Data $data | Format-SpectrePanel -Title "Results" -Border "Rounded" -Color "White"
    }

    # Print errors if they exist.
    if($object.ErrorRecord.Count -gt 0) {
        $errorRecords = @()
        $object.ErrorRecord | ForEach-Object {
            $errorRecords += $_ | Format-SpectreException -ExceptionFormat ShortenEverything
        }
        $result += $errorRecords | Format-SpectreRows | Format-SpectrePanel -Header "Errors" -Border "Rounded" -Color "Red"
    }

    return $result | Format-SpectreGrid | Format-SpectrePanel -Header "[white]Preview[/]" -Expand
}
