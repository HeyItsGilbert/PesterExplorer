# PesterExplorer PowerShell Module

PesterExplorer is a PowerShell 7+ module that provides a Terminal User Interface (TUI) to explore and navigate Pester test results using PwshSpectreConsole.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

### Prerequisites
- Requires PowerShell 7.0 or later
- Requires PwshSpectreConsole 2.3.0+ dependency for TUI functionality
- Requires Pester 5.0.0+ for test result processing
- Network access to PowerShell Gallery for dependency installation

### Environment Setup
**CRITICAL**: The build system requires PowerShell Gallery access. If PowerShell Gallery is not available, you must use an environment with internet access or pre-installed dependencies.

#### Bootstrap Process (Network Required)
```powershell
# STEP 1: Ensure PowerShell Gallery is available
Register-PSRepository -Default
Get-PSRepository  # Should show PSGallery

# STEP 2: Bootstrap dependencies
.\build.ps1 -Task Init -Bootstrap
```
**TIMING**: Bootstrap takes approximately 2-5 minutes depending on network speed. NEVER CANCEL - Set timeout to 10+ minutes.

### Build and Test Process

#### Build the Module
```powershell
# Run default build task (which runs Test)
.\build.ps1
```
**TIMING**: Build + Test takes approximately 5-10 minutes. NEVER CANCEL - Set timeout to 15+ minutes.

#### Available Build Tasks
```powershell
# List all available build tasks
.\build.ps1 -Help
```

#### Run Tests Only
```powershell
# Run Pester tests
.\build.ps1 -Task Test
```
**TIMING**: Test suite takes approximately 2-5 minutes. NEVER CANCEL - Set timeout to 10+ minutes.

#### Code Analysis
```powershell
# Run PSScriptAnalyzer (works without dependencies)
Invoke-ScriptAnalyzer -Path ./PesterExplorer/ -Recurse -Severity Warning,Error
```
**TIMING**: Analysis takes approximately 3-5 seconds.

#### Syntax Validation  
```powershell
# Validate all PowerShell files for syntax errors (works offline)
Get-ChildItem -Path . -Filter '*.ps1' -Recurse | ForEach-Object {
    try {
        $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $_.FullName -Raw), [ref]$null)
        Write-Host "✓ $($_.Name) - Syntax OK"
    } catch {
        Write-Host "✗ $($_.Name) - Syntax Error: $_"
    }
}
```
**TIMING**: Syntax validation takes approximately 1-2 seconds for all files.

## Module Usage

### Key Functions
The module exports two main functions:
- `Show-PesterResult` - Interactive TUI for exploring Pester results
- `Show-PesterResultTree` - Tree view display of Pester results

### Basic Usage Example
```powershell
# STEP 1: Import the module (requires dependencies installed)
Import-Module ./PesterExplorer/PesterExplorer.psd1

# STEP 2: Run Pester tests with PassThru to get result object
$pesterResult = Invoke-Pester ./tests/ -PassThru

# STEP 3: Explore results interactively
Show-PesterResult $pesterResult

# OR: View as tree structure
Show-PesterResultTree $pesterResult
```

### Required Test Data
To test the module functionality, you need actual Pester test results:
```powershell
# Example: Create test results from the module's own test fixture (works without dependencies)
$testResults = Invoke-Pester ./tests/fixtures/Example.ps1 -PassThru -Output None
# This creates a Pester.Run object with 1 container, 4 tests (1 passed, 3 failed/skipped/inconclusive)
```

**VALIDATION SCENARIO**: After making changes to the module, always test the complete user workflow:
```powershell
# STEP 1: Validate you can create test results
$pesterResult = Invoke-Pester ./tests/fixtures/Example.ps1 -PassThru -Output None
Write-Host "✓ Created Pester result: $($pesterResult.TotalCount) tests"

# STEP 2: Try to import module (will fail without dependencies but validates structure)
try {
    Import-Module ./PesterExplorer/PesterExplorer.psd1 -Force
    Write-Host "✓ Module imported successfully"
    
    # STEP 3: Test main functions (requires PwshSpectreConsole)
    Show-PesterResult $pesterResult
    Write-Host "✓ Show-PesterResult executed successfully"
} catch {
    Write-Host "⚠ Module functions require PwshSpectreConsole dependency: $_"
}
```

## Validation Requirements

### Always Run These Validation Steps
1. **Syntax Validation**: All PowerShell files must have valid syntax
   ```powershell
   # Validates all .ps1 files for syntax errors
   Get-ChildItem -Path . -Filter '*.ps1' -Recurse | ForEach-Object {
       [System.Management.Automation.PSParser]::Tokenize((Get-Content $_.FullName -Raw), [ref]$null)
   }
   ```

2. **Code Analysis**: Run PSScriptAnalyzer to check code quality
   ```powershell
   Invoke-ScriptAnalyzer -Path ./PesterExplorer/ -Recurse -Severity Warning,Error
   ```

3. **Module Structure**: Verify module structure is intact
   ```powershell
   # Check module manifest (will fail if dependencies not installed, but validates structure)
   try {
       Test-ModuleManifest ./PesterExplorer/PesterExplorer.psd1
       Write-Host "✓ Module manifest is valid"
   } catch {
       Write-Host "⚠ Module manifest validation failed (expected if dependencies not installed): $_"
   }
   
   # Verify all functions are present
   Write-Host "Public functions:"
   Get-ChildItem ./PesterExplorer/Public/*.ps1 | ForEach-Object { Write-Host "  - $($_.Name)" }
   Write-Host "Private functions:"  
   Get-ChildItem ./PesterExplorer/Private/*.ps1 | ForEach-Object { Write-Host "  - $($_.Name)" }
   ```

## Environment Limitations

### Network Access Required For
- Installing dependencies via PowerShell Gallery
- Running the complete build process
- Installing psake, PowerShellBuild, and other build tools
- Installing PwshSpectreConsole dependency

### What Works Without Network Access
- Syntax validation of PowerShell files
- PSScriptAnalyzer code analysis
- Module structure verification
- Direct PowerShell script testing (without dependencies)

### Fallback Instructions When PSGallery Is Unavailable
If you encounter PSGallery access issues:

1. **Document the Limitation**: Note that build requires network access
2. **Use Syntax Validation**: Verify code changes don't introduce syntax errors
3. **Use PSScriptAnalyzer**: Ensure code quality standards are met
4. **Manual Testing**: Test individual functions where possible
5. **Environment Note**: Add note that full testing requires proper PowerShell Gallery access

## Repository Structure

```
/
├── .github/workflows/          # CI/CD workflows (uses shared workflows)
├── PesterExplorer/            # Main module directory
│   ├── PesterExplorer.psd1    # Module manifest
│   ├── PesterExplorer.psm1    # Module script (dot-sources functions)
│   ├── Public/                # Exported functions
│   │   ├── Show-PesterResult.ps1
│   │   └── Show-PesterResultTree.ps1
│   └── Private/               # Internal helper functions
├── tests/                     # Pester test files
│   ├── fixtures/              # Test data
│   └── *.tests.ps1           # Test files
├── docs/                      # Documentation
├── build.ps1                  # Build script
├── psakeFile.ps1             # Build configuration
├── requirements.psd1         # Dependency definitions
└── README.md                 # Project documentation
```

## Common Tasks

### Working with Tests
- Test files are in `./tests/` directory
- Test fixtures are in `./tests/fixtures/`
- Tests require BuildHelpers environment variables to be set
- Tests expect module to be built to `./Output/` directory structure

### Making Changes
1. **Always run syntax validation** after editing any .ps1 file
2. **Always run PSScriptAnalyzer** before committing changes
3. **Test module import** after significant changes (when dependencies available)
4. **Update documentation** if changing public function interfaces
5. **Update CHANGELOG.md** for any functional changes

### Dependencies to Know About
- **Pester** (5.0.0+): Testing framework and result object provider
- **PwshSpectreConsole** (2.3.0+): TUI framework dependency (required for main functionality)
- **PSScriptAnalyzer** (1.24.0+): Code quality analysis
- **psake** (4.9.0): Build automation tool
- **PowerShellBuild** (0.6.1+): PowerShell module build tasks
- **BuildHelpers** (2.0.16+): Build environment helpers

## Troubleshooting

### "PSGallery repository not found"
- This indicates network access issues or PowerShell Gallery not being registered
- Try: `Register-PSRepository -Default` or `Register-PSResourceRepository -PSGallery -Trusted`
- If it fails, document the network limitation and use offline validation methods

### "Required module not loaded" 
- This occurs when trying to import the module without dependencies
- Ensure PwshSpectreConsole is installed: `Install-Module PwshSpectreConsole -Scope CurrentUser`
- Or use PSResourceGet: `Install-PSResource -Name PwshSpectreConsole -Repository PSGallery -Scope CurrentUser -TrustRepository`

### Tests expect module in Output directory
- The build process copies the module to `./Output/PesterExplorer/[version]/`
- Tests look for the built module in this location  
- Without successful build, most tests will fail

### Network Connectivity Issues
If you encounter "Name or service not known" errors:
- This indicates blocked access to PowerShell Gallery
- Document this limitation in your changes
- Use offline validation methods (syntax check, PSScriptAnalyzer)
- Note that full functionality testing requires network access

### Build Process Failures
If bootstrap or build fails:
- Check that PowerShell 7.0+ is available: `pwsh --version`
- Verify PSGallery access: `Get-PSRepository` or `Get-PSResourceRepository`
- Document timing: Bootstrap typically takes 2-5 minutes, builds take 5-10 minutes
- **CRITICAL**: Never cancel long-running build operations

## CI/CD Integration

### GitHub Workflows
- **CI.yaml**: Runs module CI checks (uses shared workflow)
- **Publish.yaml**: Publishes to PowerShell Gallery (uses shared workflow)
- **pages.yaml**: Publishes documentation to GitHub Pages

### Shared Workflows
The project uses shared workflows from `HeyItsGilbert/.github` repository, which handle the actual build and test logic.