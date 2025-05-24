function Get-ListPanel {
    [CmdletBinding()]
    param (
        [array]
        $List,
        [string]
        $SelectedItem
    )
    $resultList = $List | ForEach-Object {
        $name = $_
        if ($name -eq $SelectedItem) {
            $name = "[Turquoise2]$($name)[/]"
        }
        return $name
    }
    return $resultList | Format-SpectreRows | Format-SpectrePanel -Header "[white]List[/]" -Expand
}
