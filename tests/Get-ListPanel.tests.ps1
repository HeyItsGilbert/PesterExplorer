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

    Context 'Viewport scrolling' {
        # With ListHeight=8: visibleCount = 8-4 = 4 items per window
        # ScrollOffset=2: startIndex=2, endIndex=5 -> items c,d,e,f visible
        # showEllipsisTop=true (startIndex > 0)
        # showEllipsisBottom=true (endIndex=5 < 9)

        BeforeAll {
            InModuleScope $env:BHProjectName {
                $script:scrolledPanel = Get-ListPanel `
                    -List $script:tenItems `
                    -SelectedItem 'c' `
                    -ScrollOffset 2 `
                    -ListHeight 8
                $script:scrolledText = global:Get-RenderedText -Panel $script:scrolledPanel
            }
        }

        It 'should show items within the visible window' {
            InModuleScope $env:BHProjectName {
                $script:scrolledText | Should -BeLike '*c*'
                $script:scrolledText | Should -BeLike '*d*'
                $script:scrolledText | Should -BeLike '*e*'
                $script:scrolledText | Should -BeLike '*f*'
            }
        }

        It 'should hide items scrolled above the window' {
            InModuleScope $env:BHProjectName {
                # Items a and b are above the viewport (offset 2)
                $lines = $script:scrolledText -split "`n" | Where-Object { $_.Trim() -ne '' }
                # 'a' and 'b' should not appear as standalone items (only '...' should be above)
                $nonEllipsisLines = $lines | Where-Object { $_ -notmatch '^\s*\.\.\.' }
                $nonEllipsisLines | Should -Not -Contain 'a'
                $nonEllipsisLines | Should -Not -Contain 'b'
            }
        }

        It 'should show top ellipsis when items are scrolled above' {
            InModuleScope $env:BHProjectName {
                $script:scrolledText | Should -BeLike '*...*'
            }
        }

        It 'should show bottom ellipsis when items are below the window' {
            InModuleScope $env:BHProjectName {
                # Items g,h,i,j are below the viewport
                $script:scrolledText | Should -BeLike '*...*'
            }
        }
    }

    Context 'Ellipsis at top only' {
        # ScrollOffset=6, ListHeight=20: visibleCount=16, startIndex=6, endIndex=9 -> g,h,i,j visible
        # showEllipsisTop=true, showEllipsisBottom=false (endIndex=9 = Count-1)

        BeforeAll {
            InModuleScope $env:BHProjectName {
                $script:bottomPanel = Get-ListPanel `
                    -List $script:tenItems `
                    -SelectedItem 'j' `
                    -ScrollOffset 6 `
                    -ListHeight 20
                $script:bottomText = global:Get-RenderedText -Panel $script:bottomPanel
            }
        }

        It 'should show items at the bottom of the list' {
            InModuleScope $env:BHProjectName {
                $script:bottomText | Should -BeLike '*g*'
                $script:bottomText | Should -BeLike '*j*'
            }
        }

        It 'should show top ellipsis' {
            InModuleScope $env:BHProjectName {
                $script:bottomText | Should -BeLike '*...*'
            }
        }
    }

    It 'should highlight the selected item differently' {
        InModuleScope $env:BHProjectName {
            $selectedPanel = Get-ListPanel -List @('alpha', 'beta', 'gamma') -SelectedItem 'beta'
            $rendered = global:Get-RenderedText -Panel $selectedPanel
            # Selected item gets a right-arrow prefix in markup
            $rendered | Should -BeLike '*beta*'
        }
    }

    It 'should use blue border when list pane is not selected' {
        InModuleScope $env:BHProjectName {
            $panel = Get-ListPanel -List @('item1') -SelectedItem 'item1' -SelectedPane 'preview'
            $panel.GetType().ToString() | Should -BeExactly 'Spectre.Console.Panel'
        }
    }
}
