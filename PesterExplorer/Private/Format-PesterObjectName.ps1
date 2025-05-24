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
    process {
        $type = $Object.GetType().Name
        $name = $Object.Name
        if ($null -eq $name) {
            $name = $type | Get-SpectreEscapedText
        }
        if ($null -ne $Object.ExpandedName) {
            $name = $Object.ExpandedName | Get-SpectreEscapedText
        }
        $icon = switch ($Object.Result) {
            'Passed' {
                ":check_mark_button:"
            }
            'Failed' {
                ":cross_mark:"
            }
            'Skipped' {
                ":three_o_clock:"
            }
            'Inconclusive' {
                ":exclamation_question_mark:"
            }
            default {
                Write-Verbose "No icon for result: $($Object.Result)"
            }
        }
        $color = switch ($Object.Result) {
            'Passed' { 'green' }
            'Failed' { 'red' }
            'Skipped' { 'yellow' }
            'Inconclusive' { 'orange' }
            default { 'white' }
        }
        $finalName = if ($NoColor) {
            $name
        } else {
            "[${color}]${icon} $name[/]"
        }
        return $finalName
    }
}
