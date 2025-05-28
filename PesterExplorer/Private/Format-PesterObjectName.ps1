function Format-PesterObjectName {
    <#
    .SYNOPSIS
    Format the name of a Pester object for display.

    .DESCRIPTION
    This function formats the name of a Pester object for display in a way that is compatible with Spectre.Console.
    It uses the object's name and result to determine the appropriate icon and color for display.
    It returns a string that can be used in Spectre.Console output.

    .PARAMETER Object
    The Pester object to format. This should be a Pester Run or TestResult object.
    It is mandatory and can be piped in.

    .PARAMETER NoColor
    A switch to disable color formatting in the output. If specified, the name will be returned without any color
    or icon.

    .EXAMPLE
    $pesterResult.Containers[0].Blocks[0] | Format-PesterObjectName

    This would format the name of the first block in the first container of a Pester result,
    returning a string with the appropriate icon and color based on the result of the test.
    #>
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
