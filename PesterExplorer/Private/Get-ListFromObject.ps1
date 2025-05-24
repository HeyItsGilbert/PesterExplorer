function Get-ListFromObject {
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param (
        [Parameter(Mandatory = $true)]
        $Object
    )
    $previousTest = ".." # :up_left_arrow:
    $hash = [ordered]@{
        $previousTest = @()
    }
    # This can be several types of Pester objects
    switch ($Object.GetType().Name) {
        'Run' {
            $hash.Remove($previousTest)
            # This is the top-level object. Return the container names.
            $Object.Containers | ForEach-Object {
                $hash[$_.Name] = $_
            }
        }
        'Container' {
            # This is a container. Return the blocks.
            $Object.Blocks | ForEach-Object {
                $name = $_ | Format-PesterObjectName -NoColor
                $hash[$name] = $_
            }
        }
        'Block' {
            # This is a block. Return the tests.
            $Object.Order | ForEach-Object {
                $name = $_ | Format-PesterObjectName -NoColor
                $hash[$name] = $_
            }
        }
        'List`1' {
            # This is a list. Return the items.
            $Object | ForEach-Object {
                $name = $_ | Format-PesterObjectName -NoColor
                $hash[$name] = $_
            }
        }
        'Test' {
            # This is a test. Return the test name.
            #$name = $_ | Format-PesterObjectName -NoColor
            #$hash[$name] = $_
        }
        default { Write-Error "Unsupported object type: $($Object.GetType().Name)" }
    }
    return $hash
}
