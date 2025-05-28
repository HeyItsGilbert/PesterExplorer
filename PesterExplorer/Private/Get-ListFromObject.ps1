function Get-ListFromObject {
    <#
    .SYNOPSIS
    Create a list from a Pester object for creating the items for the list.

    .DESCRIPTION
    This function takes a Pester object (Run, Container, Block, or List) and
    formats it into an ordered dictionary that can be used to display a tree
    structure in a TUI (Text User Interface). It handles different types of
    Pester objects, extracting relevant information such as container names,
    block names, and test names. The function returns an ordered dictionary
    where the keys are formatted names and the values are the corresponding
    Pester objects.

    .PARAMETER Object
    The Pester object to format. This can be a Run, Container, Block, or List
    object. The function will traverse the object and its children, formatting
    them into an ordered dictionary structure.

    .EXAMPLE
    $run = Invoke-Pester -Path 'tests' -PassThru
    $list = Get-ListFromObject -Object $run

    This example retrieves a Pester run object and formats it into an ordered
    dictionary for tree display.
    #>
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
