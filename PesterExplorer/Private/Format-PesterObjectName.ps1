function Format-PesterObjectName {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        $Object,
        [Switch]
        $NoColor
    )
    $type = $Object.GetType().Name
    $name = $Object.Name
    if ($null -eq $name) {
        $name = $type | Get-SpectreEscapedText
    }
    if ($null -ne $Object.ExpandedName) {
        $name = $Object.ExpandedName | Get-SpectreEscapedText
    }
    if ($NoColor) {
        return $name | Get-SpectreEscapedText
    }
    $finalName = switch ($Object.Result) {
        'Passed' {
            "[green]:check_mark_button: $name[/]"
        }
        'Failed' {
            "[red]:cross_mark: $name[/]"
        }
        'Skipped' {
            "[yellow]:three_o_clock: $name[/]"
        }
        'Inconclusive' {
            "[orange]:exclamation_question_mark: $name[/]"
        }
        default {
            "[white]$name[/]"
        }
    }
    return $finalName
}
