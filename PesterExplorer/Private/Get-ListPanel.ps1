function Get-ListPanel {
    [CmdletBinding()]
    param (
        [array]
        $List,
        [string]
        $SelectedItem
    )
    $unselectedStyle = @{
        RootColor      = [Spectre.Console.Color]::Grey
        SeparatorColor = [Spectre.Console.Color]::Grey
        StemColor      = [Spectre.Console.Color]::Grey
        LeafColor      = [Spectre.Console.Color]::White
    }
    $results = $List | ForEach-Object {
        $name = $_
        if($name -eq '..') {
            # This is a parent item, so we show it as a folder
            if ($name -eq $SelectedItem) {
                Write-SpectreHost ":up_arrow: [Turquoise2]$name[/]" -PassThru | Format-SpectrePadded -Padding 1
            } else {
                Write-SpectreHost "$name" -PassThru | Format-SpectrePadded -Padding 0
            }
        }
        elseif(Test-Path $name){
            $relativePath = [System.IO.Path]::GetRelativePath(
                (Get-Location).Path,
                $name
            )
            if ($name -eq $SelectedItem) {
                Format-SpectreTextPath -Path $relativePath | Format-SpectrePadded -Padding 1
            } else {
                Format-SpectreTextPath -Path $relativePath -PathStyle $unselectedStyle | Format-SpectrePadded -Padding 0
            }
        }
        else {
            if ($name -eq $SelectedItem) {
                Write-SpectreHost ":right_arrow: [Turquoise2]$name[/]" -PassThru | Format-SpectrePadded -Padding 1
            } else {
                Write-SpectreHost $name -PassThru | Format-SpectrePadded -Padding 0
            }
        }
    }
    $results | Format-SpectreRows | Format-SpectrePanel -Header "[white]List[/]" -Expand
}
