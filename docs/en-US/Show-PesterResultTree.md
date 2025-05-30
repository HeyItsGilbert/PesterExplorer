---
external help file: PesterExplorer-help.xml
Module Name: PesterExplorer
online version:
schema: 2.0.0
---

# Show-PesterResultTree

## SYNOPSIS
Show a Pester result in a tree format using Spectre.Console.

## SYNTAX

```
Show-PesterResultTree [[-PesterResult] <Run>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
This function takes a Pester result object and formats it into a tree
structure using Spectre.Console.
It is useful for visualizing the structure
of Pester results such as runs, containers, blocks, and tests.

## EXAMPLES

### EXAMPLE 1
```
$pesterResult = Invoke-Pester -Path "path\to\tests.ps1" -PassThru
Show-PesterResultTree -PesterResult $pesterResult
```

This example runs Pester tests and displays the results in a tree format.

## PARAMETERS

### -PesterResult
The Pester result object to display.
This should be a Pester Run object.

```yaml
Type: Run
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Void
## NOTES

## RELATED LINKS
