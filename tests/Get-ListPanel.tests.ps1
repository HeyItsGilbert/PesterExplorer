Describe 'Get-ListPanel' {
    BeforeAll {
        . (Join-Path $PSScriptRoot 'Helpers.ps1')
        $manifest = Import-PowerShellDataFile -Path $env:BHPSModuleManifest
        $outputDir = Join-Path -Path $env:BHProjectPath -ChildPath 'Output'
        $outputModDir = Join-Path -Path $outputDir -ChildPath $env:BHProjectName
        $outputModVerDir = Join-Path -Path $outputModDir -ChildPath $manifest.ModuleVersion
        $outputModVerManifest = Join-Path -Path $outputModVerDir -ChildPath "$($env:BHProjectName).psd1"

        # Remove all versions of the module from the session. Pester can't handle multiple versions.
        Get-Module $env:BHProjectName | Remove-Module -Force -ErrorAction Ignore
        Import-Module -Name $outputModVerManifest -Verbose:$false -ErrorAction Stop

        InModuleScope $env:BHProjectName {
            $script:tenItems = @('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j')

            # Viewport scrolling panel: ScrollOffset=2, ListHeight=8
            # visibleCount = 8-4 = 4; items c,d,e,f visible; top and bottom ellipsis shown
            $script:scrolledPanel = Get-ListPanel `
                -List $script:tenItems `
                -SelectedItem 'c' `
                -ScrollOffset 2 `
                -ListHeight 8
            $script:scrolledText = global:Get-RenderedText -Panel $script:scrolledPanel

            # Bottom-of-list panel: ScrollOffset=6, ListHeight=20
            # visibleCount = 16; items g,h,i,j visible; top ellipsis only
            $script:bottomPanel = Get-ListPanel `
                -List $script:tenItems `
                -SelectedItem 'j' `
                -ScrollOffset 6 `
                -ListHeight 20
            $script:bottomText = global:Get-RenderedText -Panel $script:bottomPanel
        }
    }

    It 'should return a Spectre.Console.Panel object' {
        InModuleScope $env:BHProjectName {
            $panel = Get-ListPanel -List @('item1', 'item2') -SelectedItem 'item1'
            $panel.GetType().ToString() | Should -BeExactly 'Spectre.Console.Panel'
        }
    }

    It 'should show all items when list fits within available height' {
        InModuleScope $env:BHProjectName {
            $panel = Get-ListPanel -List $script:tenItems -SelectedItem 'a' -ListHeight 20
            $rendered = global:Get-RenderedText -Panel $panel
            foreach ($item in $script:tenItems) {
                $rendered | Should -BeLike "*$item*"
            }
        }
    }

    It 'should show all items when ListHeight is 0 (default, no constraint)' {
        InModuleScope $env:BHProjectName {
            $panel = Get-ListPanel -List $script:tenItems -SelectedItem 'a'
            $rendered = global:Get-RenderedText -Panel $panel
            foreach ($item in $script:tenItems) {
                $rendered | Should -BeLike "*$item*"
            }
        }
    }

    It 'should show only items within the visible window when scrolled' {
        InModuleScope $env:BHProjectName {
            $script:scrolledText | Should -BeLike '*c*'
            $script:scrolledText | Should -BeLike '*d*'
            $script:scrolledText | Should -BeLike '*e*'
            $script:scrolledText | Should -BeLike '*f*'
        }
    }

    It 'should show top ellipsis when items are scrolled above the window' {
        InModuleScope $env:BHProjectName {
            $script:scrolledText | Should -BeLike '*...*'
        }
    }

    It 'should show bottom ellipsis when items are below the window' {
        InModuleScope $env:BHProjectName {
            # Both top and bottom ellipsis are present since items a-b are above and g-j below
            $script:scrolledText | Should -BeLike '*...*'
        }
    }

    It 'should show visible items when scrolled to the bottom' {
        InModuleScope $env:BHProjectName {
            $script:bottomText | Should -BeLike '*g*'
            $script:bottomText | Should -BeLike '*j*'
        }
    }

    It 'should show top ellipsis when scrolled to the bottom' {
        InModuleScope $env:BHProjectName {
            $script:bottomText | Should -BeLike '*...*'
        }
    }

    It 'should highlight the selected item in the rendered output' {
        InModuleScope $env:BHProjectName {
            $panel = Get-ListPanel -List @('alpha', 'beta', 'gamma') -SelectedItem 'beta'
            $rendered = global:Get-RenderedText -Panel $panel
            $rendered | Should -BeLike '*beta*'
        }
    }

    It 'should return a Panel when list pane is not selected' {
        InModuleScope $env:BHProjectName {
            $panel = Get-ListPanel -List @('item1') -SelectedItem 'item1' -SelectedPane 'preview'
            $panel.GetType().ToString() | Should -BeExactly 'Spectre.Console.Panel'
        }
    }
}
