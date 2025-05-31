Describe 'Get-TitlePanel' {
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
            $title = Get-TitlePanel
            $title.GetType().ToString() | Should -BeExactly 'Spectre.Console.Panel'
        }
    }

    It 'should print Pester Explorer with current date' {
        InModuleScope $env:BHProjectName {
            Mock -CommandName 'Get-Date' -MockWith { '2025-01-10 12:00:00' }
            $title = Get-TitlePanel
            $render = $title.Render($script:renderOptions, $script:ContainerWidth)
            # These are rendered segments.
            (
                'Pester',
                'Explorer',
                '2025-01-10',
                '12:00:00'
            ) | ForEach-Object {
                $render.Text | Should -Contain $_
            }
        }
    }

    It 'should include the Pester object type and name if provided' {
        InModuleScope $env:BHProjectName {
            $pesterBlock = [Pester.Block]::Create()
            $pesterBlock.Name = 'Blockhead'
            $pesterBlock.Result = 'Failed'
            $titleWithItem = Get-TitlePanel -Item $pesterBlock
            $renderWithItem = $titleWithItem.Render($script:renderOptions, $script:ContainerWidth)
            $renderWithItem.Text | Should -Contain 'Block:'
            $renderWithItem.Text | Should -Contain 'Blockhead'
        }
    }
}
