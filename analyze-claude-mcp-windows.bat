@echo off
REM Claude Desktop & MCP Server Quick Analysis Script
REM This is a simpler version that creates a basic report

setlocal enabledelayedexpansion

echo ======================================
echo Claude Desktop ^& MCP Server Analysis
echo ======================================
echo.

set OUTPUT=%USERPROFILE%\Desktop\claude-mcp-analysis.txt
echo Analysis Report > "%OUTPUT%"
echo Generated: %date% %time% >> "%OUTPUT%"
echo ====================================== >> "%OUTPUT%"
echo. >> "%OUTPUT%"

REM Check AppData Claude directories
echo Checking Claude Desktop installations...
echo. >> "%OUTPUT%"
echo --- Claude Desktop Directories --- >> "%OUTPUT%"

set CLAUDE_DIR=%APPDATA%\Claude
if exist "%CLAUDE_DIR%" (
    echo [FOUND] %CLAUDE_DIR%
    echo Found: %CLAUDE_DIR% >> "%OUTPUT%"

    if exist "%CLAUDE_DIR%\claude_desktop_config.json" (
        echo   [FOUND] claude_desktop_config.json
        echo. >> "%OUTPUT%"
        echo Config file: %CLAUDE_DIR%\claude_desktop_config.json >> "%OUTPUT%"
        echo Content: >> "%OUTPUT%"
        type "%CLAUDE_DIR%\claude_desktop_config.json" >> "%OUTPUT%"
        echo. >> "%OUTPUT%"
    )

    echo Files in Claude directory: >> "%OUTPUT%"
    dir /b "%CLAUDE_DIR%" >> "%OUTPUT%"
    echo. >> "%OUTPUT%"
) else (
    echo [NOT FOUND] %CLAUDE_DIR%
    echo Not found: %CLAUDE_DIR% >> "%OUTPUT%"
)

REM Check user-specific directories
echo.
echo Checking user directories...
echo. >> "%OUTPUT%"
echo --- User Directories --- >> "%OUTPUT%"

set USER_DIRS=C:\Users\neco.roknic C:\Users\neco.roknic.yourit

for %%D in (%USER_DIRS%) do (
    if exist "%%D\AppData\Roaming\Claude" (
        echo [FOUND] %%D\AppData\Roaming\Claude
        echo Found: %%D\AppData\Roaming\Claude >> "%OUTPUT%"

        if exist "%%D\AppData\Roaming\Claude\claude_desktop_config.json" (
            echo   [FOUND] claude_desktop_config.json
            echo Config: %%D\AppData\Roaming\Claude\claude_desktop_config.json >> "%OUTPUT%"
            type "%%D\AppData\Roaming\Claude\claude_desktop_config.json" >> "%OUTPUT%"
            echo. >> "%OUTPUT%"
        )
    ) else (
        echo [NOT FOUND] %%D\AppData\Roaming\Claude
        echo Not found: %%D\AppData\Roaming\Claude >> "%OUTPUT%"
    )
)

REM Check project directories
echo.
echo Checking project directories...
echo. >> "%OUTPUT%"
echo --- Project Directories --- >> "%OUTPUT%"

if exist "C:\Projekte" (
    echo [FOUND] C:\Projekte
    echo Found: C:\Projekte >> "%OUTPUT%"
    echo Searching for MCP-related files... >> "%OUTPUT%"

    REM Search for MCP config files
    dir /s /b "C:\Projekte\*mcp*.json" 2>nul >> "%OUTPUT%"
    dir /s /b "C:\Projekte\*mcp*.js" 2>nul >> "%OUTPUT%"
    echo. >> "%OUTPUT%"
) else (
    echo [NOT FOUND] C:\Projekte
    echo Not found: C:\Projekte >> "%OUTPUT%"
)

REM Check Python directories
echo.
echo Checking Python installations...
echo. >> "%OUTPUT%"
echo --- Python Directories --- >> "%OUTPUT%"

for %%P in (C:\Python313 C:\Python314) do (
    if exist "%%P" (
        echo [FOUND] %%P
        echo Found: %%P >> "%OUTPUT%"

        if exist "%%P\python.exe" (
            echo   Python executable found
            echo   Python executable: %%P\python.exe >> "%OUTPUT%"

            REM Try to check pip for MCP packages
            "%%P\python.exe" -m pip list 2>nul | findstr /i "mcp" >> "%OUTPUT%"
        )
        echo. >> "%OUTPUT%"
    ) else (
        echo [NOT FOUND] %%P
        echo Not found: %%P >> "%OUTPUT%"
    )
)

REM Check for globally installed MCP servers
echo.
echo Checking global npm packages...
echo. >> "%OUTPUT%"
echo --- Global npm Packages --- >> "%OUTPUT%"

where npm >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo npm found, checking for MCP packages...
    npm list -g --depth=0 2>nul | findstr /i "modelcontextprotocol" >> "%OUTPUT%"
    echo. >> "%OUTPUT%"
) else (
    echo npm not found >> "%OUTPUT%"
)

echo.
echo ======================================
echo Analysis Complete!
echo ======================================
echo.
echo Results saved to: %OUTPUT%
echo Opening file...
echo.

start notepad.exe "%OUTPUT%"

pause
