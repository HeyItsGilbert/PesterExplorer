---
external help file: PesterExplorer-help.xml
Module Name: PesterExplorer
online version:
schema: 2.0.0
---

# Show-PesterResult

## SYNOPSIS
Open a TUI to explore the Pester result object.

## SYNTAX

```
Show-PesterResult [-PesterResult] <Run> [-NoShortcutPanel] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Show a Pester result in a TUI (Text User Interface) using Spectre.Console.
This function builds a layout with a header, a list of items, and a preview panel.

## EXAMPLES

### EXAMPLE 1
```
$pesterResult = Invoke-Pester -Path "path\to\tests.ps1" -PassThru
Show-PesterResult -PesterResult $pesterResult
```

This example runs Pester tests and opens a TUI to explore the results.

## PARAMETERS

### -PesterResult
The Pester result object to display.
This should be a Pester Run object.

```yaml
Type: Run
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoShortcutPanel
If specified, the shortcut panel will not be displayed at the bottom of the TUI.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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
