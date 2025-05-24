function Format-PesterTreeHash {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $Object
    )
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
