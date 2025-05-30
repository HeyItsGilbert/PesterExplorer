function Get-PesterTestView {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [Pester.Test[]]
        $Test
    )
    begin {
        $rows = @()
    }
    process {
        $Test | ForEach-Object {
            $object = $_
            if($null -eq $object) {
                return
            }

            # Print the test name
            $formatSpectrePanelSplat = @{
                Header = "Test Name"
                Border = "Ascii"
                Color = "Cyan"
            }
            $rows += Format-PesterObjectName -Object $object |
                Format-SpectrePanel @formatSpectrePanelSplat

            $formatSpectrePanelSplat = @{
                Header = "Test Result"
                Border = "Rounded"
                Color = "White"
            }
            $rows += $object.Result |
                Format-SpectrePanel @formatSpectrePanelSplat

            # Show the code tested
            $formatSpectrePanelSplat = @{
                Header = "Test Code"
                Border = "Rounded"
                Color = "White"
            }
            $rows += $object.ScriptBlock |
                Get-SpectreEscapedText |
                Format-SpectrePanel @formatSpectrePanelSplat

            if($null -ne $object.StandardOutput){
                $formatSpectrePanelSplat = @{
                    Header = "Standard Output"
                    Border = "Ascii"
                    Color = "White"
                }

                $rows += $object.StandardOutput |
                    Get-SpectreEscapedText |
                    Format-SpectrePanel @formatSpectrePanelSplat
            }

            # Print errors if they exist.
            if($object.ErrorRecord.Count -gt 0) {
                $errorRecords = @()
                $formatSpectrePanelSplat = @{
                    Header = "Errors"
                    Border = "Rounded"
                    Color = "Red"
                }
                $object.ErrorRecord | ForEach-Object {
                    $errorRecords += $_ |
                        Format-SpectreException -ExceptionFormat ShortenEverything
                }
                $rows += $errorRecords |
                    Format-SpectreRows |
                    Format-SpectrePanel @formatSpectrePanelSplat
            }
        }
    }
    end {
        return $rows
    }
}
