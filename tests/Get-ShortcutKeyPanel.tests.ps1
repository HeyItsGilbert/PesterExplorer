Describe 'Get-ShortcutKeyPanel' {
    BeforeAll {
        $manifest = Import-PowerShellDataFile -Path $env:BHPSModuleManifest
        $outputDir = Join-Path -Path $env:BHProjectPath -ChildPath 'Output'
        $outputModDir = Join-Path -Path $outputDir -ChildPath $env:BHProjectName
        $outputModVerDir = Join-Path -Path $outputModDir -ChildPath $manifest.ModuleVersion
        $outputModVerManifest = Join-Path -Path $outputModVerDir -ChildPath "$($env:BHProjectName).psd1"

        # Get module commands
        # Remove all versions of the module from the session. Pester can't handle multiple versions.
        Get-Module $env:BHProjectName | Remove-Module -Force -ErrorAction Ignore
        Import-Module -Name $outputModVerManifest -Verbose:$false -ErrorAction Stop

        InModuleScope $env:BHProjectName {
            $script:ContainerWidth = 80
            $script:ContainerHeight = 5
            $size = [Spectre.Console.Size]::new($containerWidth, $containerHeight)
            $script:renderOptions = [Spectre.Console.Rendering.RenderOptions]::new(
                [Spectre.Console.AnsiConsole]::Console.Profile.Capabilities,
                $size
            )
            $script:renderOptions.Justification = $null
            $script:renderOptions.Height = $null
        }
    }
    It 'should return a Spectre.Console.Panel object' {
        InModuleScope $env:BHProjectName {
            $panel = Get-ShortcutKeyPanel
            $panel.GetType().ToString() | Should -BeExactly 'Spectre.Console.Panel'
        }
    }

    It 'should print some known keys' {
        InModuleScope $env:BHProjectName {
            Mock -CommandName 'Get-Date' -MockWith { '2025-01-10 12:00:00' }
            $panel = Get-ShortcutKeyPanel
            $render = $panel.Render($script:renderOptions, $script:ContainerWidth)
            # These are rendered segments.
            (
                'Navigate'
            ) | ForEach-Object {
                $render.Text | Should -Contain $_
            }
        }
    }
}
