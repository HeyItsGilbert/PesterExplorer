function Get-TitlePanel {
    [CmdletBinding()]
    param(
        $Item
    )
    # TODO: Add some more info to the title panel.
    $titles = @(
        "Pester Explorer - [gray]$(Get-Date)[/]"
    )
    if($null -ne $Item){
        $objectName = Format-PesterObjectName -Object $Item
        # Print what type it is and it's formatted name.
        $titles += "$($Item.GetType().Name): $($objectName)"
    }
    return $titles | Format-SpectreRows | Format-SpectreAligned -HorizontalAlignment Center -VerticalAlignment Middle | Format-SpectrePanel -Expand
}
