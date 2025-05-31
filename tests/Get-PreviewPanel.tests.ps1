Describe 'Get-PreviewPanel' {
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

        InModuleScope $env:BHProjectName {
            $script:ContainerWidth = 80
            $script:ContainerHeight = 200
            $size = [Spectre.Console.Size]::new($containerWidth, $containerHeight)
            $script:renderOptions = [Spectre.Console.Rendering.RenderOptions]::new(
                [Spectre.Console.AnsiConsole]::Console.Profile.Capabilities,
                $size
            )
            $script:renderOptions.Justification = $null
            $script:renderOptions.Height = $null
            $container = New-PesterContainer -Scriptblock {
                Describe 'Demo Tests' {
                    Context 'Contextualize It' {
                        It 'Test1' {
                            $true | Should -Be $true
                        }
                        It 'Test2' {
                            $false | Should -Be $true
                        }
                    }
                }
            }
            $script:run = Invoke-Pester -Container $container -PassThru -Output 'None'
            $script:Items = Get-ListFromObject -Object $run.Containers[0]

            $script:getPreviewPanelSplat = @{
                Items = $script:Items
                SelectedItem = 'Demo Tests'
                PreviewHeight = $script:ContainerHeight
                PreviewWidth = $script:ContainerWidth
            }
            $script:panel = Get-PreviewPanel @getPreviewPanelSplat
        }
    }
    It 'should return a Spectre.Console.Panel object' {
        InModuleScope $env:BHProjectName {
            $script:panel.GetType().ToString() | Should -BeExactly 'Spectre.Console.Panel'
        }
    }

    It 'should call breakdown chart' {
        InModuleScope $env:BHProjectName {
            Mock Format-SpectreBreakdownChart -Verifiable
            $script:panel = Get-PreviewPanel @script:getPreviewPanelSplat
            Should -Invoke Format-SpectreBreakdownChart -Exactly 1 -Scope It
        }
    }

    It 'should print "Please select an item." when SelectedItem is ".."' {
        InModuleScope $env:BHProjectName {
            $getPreviewPanelSplat = @{
                Items = $script:Items
                SelectedItem = '..'
                PreviewHeight = $script:ContainerHeight
                PreviewWidth = $script:ContainerWidth
            }
            $panel = Get-PreviewPanel @getPreviewPanelSplat
            global:Get-RenderedText -panel $panel -renderOptions $script:renderOptions -containerWidth $script:ContainerWidth |
                Should -BeLike "*Please select an item.*"
        }
    }

    It 'should print warning when the screen is too small' {
        InModuleScope $env:BHProjectName {
            $Items = Get-ListFromObject -Object $script:run.Containers[0].Blocks[0].Order[0]
            $height = 5
            $size = [Spectre.Console.Size]::new(80, $height)
            $renderOptions = [Spectre.Console.Rendering.RenderOptions]::new(
                [Spectre.Console.AnsiConsole]::Console.Profile.Capabilities,
                $size
            )
            $getPreviewPanelSplat = @{
                Items = $Items
                SelectedItem = 'Test1'
                ScrollPosition = 1
                PreviewHeight = $height
                PreviewWidth = $script:ContainerWidth
            }
            $panel = Get-PreviewPanel @getPreviewPanelSplat
            global:Get-RenderedText -panel $panel -renderOptions $renderOptions -containerWidth $script:ContainerWidth |
                Should -BeLike "*resize your terminal*"
        }
    }

    It 'should print the script block for a Test' {
        InModuleScope $env:BHProjectName {
            $Items = Get-ListFromObject -Object $script:run.Containers[0].Blocks[0].Order[0].Tests
            $getPreviewPanelSplat = @{
                Items = $Items
                SelectedItem = 'Test1'
                PreviewHeight = $script:ContainerHeight
                PreviewWidth = $script:ContainerWidth
            }
            $panel = Get-PreviewPanel @getPreviewPanelSplat
            global:Get-RenderedText -panel $panel -renderOptions $script:renderOptions -containerWidth $script:ContainerWidth |
                Should -BeLike '*$true | Should -Be $true*'
        }
    }
}
