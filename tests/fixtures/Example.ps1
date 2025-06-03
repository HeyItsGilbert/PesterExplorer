Describe 'Example Tests' {
    BeforeAll {
        $script:TestVariable = "Initial Value"
    }

    It 'should pass' {
        $script:TestVariable | Should -Be "Initial Value"
    }

    It 'should skip this' {
        Set-ItResult -Skipped 'This test is skipped intentionally.'
    }

    It 'should be inconclusive' {
        Set-ItResult -Inconclusive 'This test is inconclusive.'
    }

    It 'should be pending' {
        Set-ItResult -Pending 'This test is pending.'
    }

    AfterAll {
        $script:TestVariable = $null
    }
}
