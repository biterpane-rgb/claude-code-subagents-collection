# Claude Desktop & MCP Server Analysis Script
# This script analyzes Windows directories for Claude Desktop installations and MCP server configurations

Write-Host "=== Claude Desktop & MCP Server Analysis ===" -ForegroundColor Cyan
Write-Host ""

# Define directories to check
$directories = @(
    "C:\Users\neco.roknic",
    "C:\Users\neco.roknic\AppData\Roaming\Claude",
    "C:\Users\neco.roknic.yourit\AppData\Roaming\Claude",
    "C:\Projekte",
    "C:\Python313",
    "C:\Python314"
)

# Output file
$outputFile = "$env:USERPROFILE\Desktop\claude-mcp-analysis.txt"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Initialize output
$output = @"
Claude Desktop & MCP Server Analysis
Generated: $timestamp
======================================

"@

Write-Host "Analyzing directories..." -ForegroundColor Yellow
Write-Host ""

foreach ($dir in $directories) {
    $output += "`n--- Analyzing: $dir ---`n"
    Write-Host "Checking: $dir" -ForegroundColor Green

    if (Test-Path $dir) {
        $output += "Directory exists: YES`n"

        # Check for Claude Desktop config
        $claudeConfig = Join-Path $dir "claude_desktop_config.json"
        if (Test-Path $claudeConfig) {
            $output += "`nFound: claude_desktop_config.json`n"
            $output += "Location: $claudeConfig`n"
            $output += "Content:`n"
            $output += Get-Content $claudeConfig -Raw
            $output += "`n"
            Write-Host "  [FOUND] claude_desktop_config.json" -ForegroundColor Green
        }

        # Check for MCP server related files
        $mcpPatterns = @("*mcp*.json", "*mcp*.js", "*mcp*.ts", "*server*.json")
        foreach ($pattern in $mcpPatterns) {
            $files = Get-ChildItem -Path $dir -Filter $pattern -Recurse -ErrorAction SilentlyContinue -Depth 3
            if ($files) {
                $output += "`nMCP-related files ($pattern):`n"
                foreach ($file in $files) {
                    $output += "  - $($file.FullName)`n"
                    Write-Host "  [FOUND] $($file.Name)" -ForegroundColor Cyan
                }
            }
        }

        # Check for node_modules with MCP packages
        $nodeModules = Get-ChildItem -Path $dir -Filter "node_modules" -Directory -Recurse -ErrorAction SilentlyContinue -Depth 2
        if ($nodeModules) {
            foreach ($nm in $nodeModules) {
                $mcpPackages = Get-ChildItem -Path $nm.FullName -Filter "@modelcontextprotocol" -Directory -ErrorAction SilentlyContinue
                if ($mcpPackages) {
                    $output += "`nMCP packages in $($nm.FullName):`n"
                    $servers = Get-ChildItem -Path $mcpPackages.FullName -Directory -ErrorAction SilentlyContinue
                    foreach ($server in $servers) {
                        $output += "  - $($server.Name)`n"
                        Write-Host "  [FOUND] MCP Server: $($server.Name)" -ForegroundColor Yellow

                        # Check for package.json
                        $packageJson = Join-Path $server.FullName "package.json"
                        if (Test-Path $packageJson) {
                            $pkg = Get-Content $packageJson -Raw | ConvertFrom-Json
                            $output += "    Version: $($pkg.version)`n"
                            $output += "    Description: $($pkg.description)`n"
                        }
                    }
                }
            }
        }

        # Check for Python MCP servers
        if ($dir -like "*Python*") {
            $output += "`nPython environment detected`n"

            # Check for pip installed MCP packages
            $pythonExe = Get-ChildItem -Path $dir -Filter "python.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($pythonExe) {
                $output += "Python executable: $($pythonExe.FullName)`n"
                Write-Host "  [FOUND] Python: $($pythonExe.FullName)" -ForegroundColor Magenta

                # Try to list pip packages
                try {
                    $pipList = & $pythonExe.FullName -m pip list 2>&1 | Select-String -Pattern "mcp"
                    if ($pipList) {
                        $output += "MCP-related pip packages:`n"
                        $output += $pipList -join "`n"
                        $output += "`n"
                        Write-Host "  [FOUND] MCP pip packages" -ForegroundColor Magenta
                    }
                } catch {
                    $output += "Could not query pip packages`n"
                }
            }

            # Check for MCP server Python files
            $pyFiles = Get-ChildItem -Path $dir -Filter "*mcp*.py" -Recurse -ErrorAction SilentlyContinue -Depth 3
            if ($pyFiles) {
                $output += "`nMCP Python files:`n"
                foreach ($pyFile in $pyFiles) {
                    $output += "  - $($pyFile.FullName)`n"
                    Write-Host "  [FOUND] $($pyFile.Name)" -ForegroundColor Magenta
                }
            }
        }

        # Check for .env files (may contain API keys)
        $envFiles = Get-ChildItem -Path $dir -Filter ".env*" -Recurse -ErrorAction SilentlyContinue -Depth 2
        if ($envFiles) {
            $output += "`nEnvironment files (may contain API keys):`n"
            foreach ($envFile in $envFiles) {
                $output += "  - $($envFile.FullName)`n"
                Write-Host "  [FOUND] $($envFile.Name)" -ForegroundColor Yellow

                # Show MCP/API related env vars (without values for security)
                $content = Get-Content $envFile.FullName -ErrorAction SilentlyContinue
                $relevantVars = $content | Select-String -Pattern "(MCP|API|KEY|TOKEN|GITHUB|POSTGRES|DATABASE)"
                if ($relevantVars) {
                    $output += "    Relevant variables (keys hidden):`n"
                    foreach ($var in $relevantVars) {
                        $varName = ($var -split "=")[0]
                        $output += "      - $varName=***`n"
                    }
                }
            }
        }

        # Check for package.json files (may indicate Node.js projects with MCP)
        $packageJsonFiles = Get-ChildItem -Path $dir -Filter "package.json" -Recurse -ErrorAction SilentlyContinue -Depth 2
        if ($packageJsonFiles) {
            foreach ($pkgFile in $packageJsonFiles) {
                $pkgContent = Get-Content $pkgFile.FullName -Raw -ErrorAction SilentlyContinue
                if ($pkgContent -match "modelcontextprotocol|@mcp") {
                    $output += "`nNode.js project with MCP dependencies:`n"
                    $output += "  Location: $($pkgFile.DirectoryName)`n"
                    $pkg = $pkgContent | ConvertFrom-Json
                    if ($pkg.dependencies) {
                        $mcpDeps = $pkg.dependencies.PSObject.Properties | Where-Object { $_.Name -like "*mcp*" -or $_.Name -like "*modelcontextprotocol*" }
                        if ($mcpDeps) {
                            $output += "  MCP Dependencies:`n"
                            foreach ($dep in $mcpDeps) {
                                $output += "    - $($dep.Name): $($dep.Value)`n"
                            }
                        }
                    }
                    if ($pkg.devDependencies) {
                        $mcpDevDeps = $pkg.devDependencies.PSObject.Properties | Where-Object { $_.Name -like "*mcp*" -or $_.Name -like "*modelcontextprotocol*" }
                        if ($mcpDevDeps) {
                            $output += "  MCP Dev Dependencies:`n"
                            foreach ($dep in $mcpDevDeps) {
                                $output += "    - $($dep.Name): $($dep.Value)`n"
                            }
                        }
                    }
                    Write-Host "  [FOUND] Node.js project with MCP at: $($pkgFile.DirectoryName)" -ForegroundColor Cyan
                }
            }
        }

    } else {
        $output += "Directory exists: NO`n"
        Write-Host "  [NOT FOUND] Directory does not exist" -ForegroundColor Red
    }

    $output += "`n"
}

# Additional: Check common Claude Desktop locations
Write-Host "`nChecking standard Claude Desktop locations..." -ForegroundColor Yellow
$standardLocations = @(
    "$env:APPDATA\Claude",
    "$env:LOCALAPPDATA\Claude",
    "$env:USERPROFILE\.claude"
)

foreach ($loc in $standardLocations) {
    if (Test-Path $loc) {
        $output += "`n--- Standard Location: $loc ---`n"
        Write-Host "Found: $loc" -ForegroundColor Green

        $claudeConfig = Join-Path $loc "claude_desktop_config.json"
        if (Test-Path $claudeConfig) {
            $output += "claude_desktop_config.json content:`n"
            $output += Get-Content $claudeConfig -Raw
            $output += "`n"
            Write-Host "  [FOUND] claude_desktop_config.json" -ForegroundColor Green
        }

        # List all files in Claude directory
        $files = Get-ChildItem -Path $loc -File -ErrorAction SilentlyContinue
        if ($files) {
            $output += "`nFiles in $loc :`n"
            foreach ($file in $files) {
                $output += "  - $($file.Name) ($([math]::Round($file.Length/1KB, 2)) KB)`n"
            }
        }
    }
}

# Check for globally installed MCP servers via npm
Write-Host "`nChecking globally installed npm packages..." -ForegroundColor Yellow
try {
    $globalPackages = npm list -g --depth=0 2>&1 | Select-String -Pattern "modelcontextprotocol"
    if ($globalPackages) {
        $output += "`n--- Global npm MCP Servers ---`n"
        $output += $globalPackages -join "`n"
        $output += "`n"
        Write-Host "[FOUND] Global MCP npm packages" -ForegroundColor Green
    }
} catch {
    $output += "npm not found or error querying global packages`n"
}

# Save output to file
$output | Out-File -FilePath $outputFile -Encoding UTF8
Write-Host "`n=== Analysis Complete ===" -ForegroundColor Cyan
Write-Host "Results saved to: $outputFile" -ForegroundColor Green
Write-Host ""
Write-Host "Opening results file..." -ForegroundColor Yellow
Start-Process notepad.exe $outputFile
