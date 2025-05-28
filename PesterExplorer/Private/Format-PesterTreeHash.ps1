function Format-PesterTreeHash {
    <#
    .SYNOPSIS
    Format a Pester object into a hashtable for tree display.

    .DESCRIPTION
    This function takes a Pester object and formats it into a hashtable that can
    be used to display a tree structure in a TUI (Text User Interface). It
    handles different types of Pester objects such as Run, Container, Block, and
    Test, recursively building a tree structure with children nodes.

    .PARAMETER Object
    The Pester object to format. This can be a Run, Container, Block, or Test
    object. The function will traverse the object and its children, formatting
    them into a hashtable structure.

    .EXAMPLE
    $run = Invoke-Pester -Path 'tests' -PassThru
    $treeHash = Format-PesterTreeHash -Object $run

    .NOTES
    This returns a hashtable with the following structure:
    @{
        Value = "Pester Run" # or the name of the object
        Children = @(
            @{
                Value = "Container Name"
                Children = @(
                    @{
                        Value = "Block Name"
                        Children = @(
                            @{
                                Value = "Test Name"
                                Children = @()
                            }
                        )
                    }
                )
            }
        )
    }
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $Object
    )
    process {
        Write-Debug "Formatting object: $($Object.Name)"
        $hash = @{
            Value = $(Format-PesterObjectName -Object $Object)
            Children = @()
        }

        if ($null -eq $Object) {
            throw "Object is null"
        }
        Write-Debug "Object type: $($Object.GetType())"
        switch -Regex ($Object.GetType().Name) {
            'List`1' {
                # This is a list. Return the items.
                $Object | Where-Object { $_ } | ForEach-Object {
                    $hash.Children += Format-PesterTreeHash -Object $_
                }
            }
            'Run' {
                $hash["Value"] = "Pester Run"
                # This is the top-level object. Return the container names.
                $Object.Containers | Where-Object { $_ } | ForEach-Object {
                    $hash.Children += Format-PesterTreeHash $_
                }
            }
            'Container' {
                # This is a container. Return the blocks.
                if ($Object.Blocks.Count -eq 0) {
                    break
                }
                $Object.Blocks | Where-Object { $_ } | ForEach-Object {
                    $hash.Children += Format-PesterTreeHash $_
                }
            }
            'Block' {
                # This is a block. Return the tests.
                if ($Object.Order.Count -eq 0) {
                    break
                }
                $Object.Order | Where-Object { $_ } | ForEach-Object {
                    $hash.Children += Format-PesterTreeHash $_
                }
            }
            'Test' {
                # Nothing
            }
            default { Write-Warning "Unsupported object type: $($Object.GetType().Name)" }
        }
        return $hash
    }
}
