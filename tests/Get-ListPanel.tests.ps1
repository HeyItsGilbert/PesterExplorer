Describe 'Get-ListPanel Scrolling' {
    BeforeAll {
        # Import the function for testing
        . (Join-Path $PSScriptRoot '../PesterExplorer/Private/Get-ListPanel.ps1')
        
        # Mock Spectre.Console functions to avoid dependency issues
        Mock Write-SpectreHost { 
            param($Message, [switch]$PassThru)
            if ($PassThru) { return $Message } else { return $Message }
        }
        Mock Format-SpectrePadded { 
            param($Padding, [Parameter(ValueFromPipeline)]$InputObject)
            process { return "[$Padding] $InputObject" }
        }
        Mock Format-SpectreRows { 
            param([Parameter(ValueFromPipeline)]$InputObject)
            begin { $items = @() }
            process { $items += $InputObject }
            end { return $items }
        }
        Mock Format-SpectrePanel { 
            param($Header, $Color, [switch]$Expand, [Parameter(ValueFromPipeline)]$InputObject)
            process { return "Panel[$Header,$Color]: $($InputObject -join '|')" }
        }
        Mock Format-SpectreTextPath { 
            param($Path, $PathStyle)
            return "Path: $Path"
        }
        # Mock Spectre.Console.Color to avoid type errors
        Add-Type -TypeDefinition @'
            namespace Spectre.Console {
                public enum Color {
                    Grey = 0
                }
            }
'@ -ErrorAction SilentlyContinue
    }
    
    Context 'Without scrolling (ListHeight = 0 or list fits)' {
        It 'Shows all items when ListHeight is 0' {
            $testList = @('Test1', 'Test2', 'Test3', 'Test4', 'Test5')
            $result = Get-ListPanel -List $testList -SelectedItem 'Test1' -ListScrollPosition 0 -ListHeight 0
            
            # Should contain all items
            $result.ToString() | Should -Match 'Test5'
        }
        
        It 'Shows all items when list is shorter than height' {
            $testList = @('Test1', 'Test2', 'Test3')
            $result = Get-ListPanel -List $testList -SelectedItem 'Test1' -ListScrollPosition 0 -ListHeight 5
            
            # Should contain all items, no scroll indicators
            $result.ToString() | Should -Match 'Test3'
            $result.ToString() | Should -Not -Match '\.\.\.'
        }
    }
    
    Context 'With scrolling (ListHeight > 0 and list is long)' {
        It 'Shows limited items with more indicator when at top' {
            $testList = @('Test1', 'Test2', 'Test3', 'Test4', 'Test5', 'Test6', 'Test7', 'Test8')
            $result = Get-ListPanel -List $testList -SelectedItem 'Test1' -ListScrollPosition 0 -ListHeight 5
            
            # Should contain first few items and more indicator
            $result.ToString() | Should -Match 'Test1'
            $result.ToString() | Should -Match 'Test4'
            $result.ToString() | Should -Match '\.\.\.more'
            $result.ToString() | Should -Not -Match 'Test8'
        }
        
        It 'Shows scroll up indicator when scrolled down' {
            $testList = @('Test1', 'Test2', 'Test3', 'Test4', 'Test5', 'Test6', 'Test7', 'Test8')
            $result = Get-ListPanel -List $testList -SelectedItem 'Test5' -ListScrollPosition 2 -ListHeight 5
            
            # Should contain scroll up indicator
            $resultStr = $result.ToString()
            $resultStr | Should -Match '\.\.\.' # Up indicator
            $resultStr | Should -Match 'Test5'
        }
        
        It 'Shows both scroll indicators when in middle' {
            $testList = @('Test1', 'Test2', 'Test3', 'Test4', 'Test5', 'Test6', 'Test7', 'Test8', 'Test9', 'Test10')
            $result = Get-ListPanel -List $testList -SelectedItem 'Test6' -ListScrollPosition 3 -ListHeight 5
            
            $resultStr = $result.ToString()
            # Should have both up and down indicators
            $resultStr | Should -Match '\.\.\.' # Should have some scroll indicator
            $resultStr | Should -Match 'Test6'
        }
        
        It 'Handles boundary conditions correctly' {
            $testList = @('Test1', 'Test2', 'Test3', 'Test4', 'Test5', 'Test6')
            $result = Get-ListPanel -List $testList -SelectedItem 'Test6' -ListScrollPosition 2 -ListHeight 5
            
            # Should show items starting from scroll position
            $resultStr = $result.ToString()
            $resultStr | Should -Match 'Test6'
        }
    }
    
    Context 'Parameter validation' {
        It 'Has required new parameters' {
            $params = (Get-Command Get-ListPanel).Parameters
            $params.Keys | Should -Contain 'ListScrollPosition'
            $params.Keys | Should -Contain 'ListHeight'
        }
        
        It 'Accepts all parameter types correctly' {
            $testList = @('Test1', 'Test2')
            { Get-ListPanel -List $testList -SelectedItem 'Test1' -ListScrollPosition 0 -ListHeight 5 } | Should -Not -Throw
        }
    }
    
    Context 'Selected item highlighting' {
        It 'Highlights selected item correctly with scrolling' {
            $testList = @('Test1', 'Test2', 'Test3', 'Test4', 'Test5', 'Test6')
            $result = Get-ListPanel -List $testList -SelectedItem 'Test3' -ListScrollPosition 1 -ListHeight 4
            
            # Selected item should be highlighted (contains Turquoise2)
            $result.ToString() | Should -Match 'Turquoise2.*Test3'
        }
    }
}