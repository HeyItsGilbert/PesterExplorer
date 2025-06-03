Describe 'Get-TitlePanel' {
    BeforeAll {
        . (Join-Path $PSScriptRoot 'Helpers.ps1')
        $manifest = Import-PowerShellDataFile -Path $env:BHPSModuleManifest
        $outputDir = Join-Path -Path $env:BHProjectPath -ChildPath 'Output'
        $outputModDir = Join-Path -Path $outputDir -ChildPath $env:BHProjectName
        $outputModVerDir = Join-Path -Path $outputModDir -ChildPath $manifest.ModuleVersion
        $outputModVerManifest = Join-Path -Path $outputModVerDir -ChildPath "$($env:BHProjectName).psd1"

        # Get module commands
        # Remove all versions of the module from the session. Pester can't handle multiple versions.
        Get-Module $env:BHProjectName | Remove-Module -Force -ErrorAction Ignore
        Import-Module -Name $outputModVerManifest -Verbose:$false -ErrorAction Stop

        InModuleScope $env:BHProjectname {
            $script:pesterResult = Invoke-Pester -PassThru -Path "$PSScriptRoot\fixtures\Example.ps1" -Output 'None'
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
            global:Get-RenderedText -Panel $title |
                Should -Contain 'Pester Explorer - 2025-01-10 12:00:00'
        }
    }

    It 'should print pester run name and type' {
        InModuleScope $env:BHProjectName {
            $titleWithItem = Get-TitlePanel -Item $script:pesterResult
            $renderWithItem = global:Get-RenderedText -Panel $titleWithItem
            $renderWithItem | Should -Match 'Run: . Pester.Run'
        }
    }

    It 'should print container name and type' {
        InModuleScope $env:BHProjectName {
            $titleWithItem = Get-TitlePanel -Item $script:pesterResult.Containers[0]
            $renderWithItem = global:Get-RenderedText -Panel $titleWithItem
            $renderWithItem | Should -BeLike '*Container:*Example.ps1'
        }
    }

    It 'should print block name and type' {
        InModuleScope $env:BHProjectName {
            $titleWithItem = Get-TitlePanel -Item $script:pesterResult.Containers[0].Blocks[0]
            $renderWithItem = global:Get-RenderedText -Panel $titleWithItem
            $renderWithItem | Should -Match 'Block: . Example Tests'
        }
    }

    Context 'Tests' {
        BeforeDiscovery {
            $pesterResult = Invoke-Pester -PassThru -Path "$PSScriptRoot\fixtures\Example.ps1" -Output 'None'
            $tests = $pesterResult.Containers[0].Blocks[0].Tests
        }

        It 'should print test name <_>' -ForEach $tests {
            InModuleScope $env:BHProjectName -ArgumentList $_ -ScriptBlock {
                param($test)
                $titleWithItem = Get-TitlePanel -Item $test
                $renderWithItem = global:Get-RenderedText -Panel $titleWithItem
                $renderWithItem | Should -Match "Test: .*$($test.Name)"
            }
        }
    }
}
