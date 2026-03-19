@echo off
setlocal EnableDelayedExpansion

:: ============================================================================
:: rentec-login.bat
:: Starts VcXsrv, SSH into VPS with X11 forwarding, runs rentec-login.sh
:: Requires: VcXsrv, PuTTY (plink.exe)
:: ============================================================================

set "SCRIPT_DIR=%~dp0"
set "CONFIG_FILE=%SCRIPT_DIR%config.ini"
set "ENV_FILE=%SCRIPT_DIR%.env"
set "VCXSRV_EXE=C:\Program Files\VcXsrv\vcxsrv.exe"
set "PLINK_EXE=C:\Program Files\PuTTY\plink.exe"

:: ── Dependency checks ────────────────────────────────────────────────────────
if not exist "%VCXSRV_EXE%" (
    echo ERROR: VcXsrv not found at:
    echo   %VCXSRV_EXE%
    echo Install from: https://sourceforge.net/projects/vcxsrv/
    pause & exit /b 1
)

if not exist "%PLINK_EXE%" (
    :: Try x86 path as fallback
    set "PLINK_EXE=C:\Program Files (x86)\PuTTY\plink.exe"
    if not exist "!PLINK_EXE!" (
        echo ERROR: plink.exe not found. Install PuTTY from: https://www.putty.org/
        pause & exit /b 1
    )
)

:: ── Config file checks ───────────────────────────────────────────────────────
if not exist "%CONFIG_FILE%" (
    echo ERROR: config.ini not found at:
    echo   %CONFIG_FILE%
    echo Copy config.ini.example to config.ini and fill in your VPS details.
    pause & exit /b 1
)

if not exist "%ENV_FILE%" (
    echo ERROR: .env not found at:
    echo   %ENV_FILE%
    echo Copy .env.example to .env and fill in your credentials.
    pause & exit /b 1
)

:: ── Parse config.ini (skip blank lines and # comments) ──────────────────────
for /f "usebackq eol=# tokens=1,* delims==" %%A in ("%CONFIG_FILE%") do (
    set "line=%%A"
    set "line=!line: =!"
    if not "!line!"=="" set "%%A=%%B"
)

:: ── Parse .env (skip blank lines and # comments) ────────────────────────────
for /f "usebackq eol=# tokens=1,* delims==" %%A in ("%ENV_FILE%") do (
    set "line=%%A"
    set "line=!line: =!"
    if not "!line!"=="" set "%%A=%%B"
)

:: ── Validate required values ─────────────────────────────────────────────────
set "MISSING="
if not defined VPS_HOST     set "MISSING=!MISSING! VPS_HOST"
if not defined VPS_USER     set "MISSING=!MISSING! VPS_USER"
if not defined VPS_SCRIPT_PATH set "MISSING=!MISSING! VPS_SCRIPT_PATH"
if not defined VPS_PASSWORD set "MISSING=!MISSING! VPS_PASSWORD"
if not defined RENTEC_USERNAME set "MISSING=!MISSING! RENTEC_USERNAME"
if not defined RENTEC_PASSWORD set "MISSING=!MISSING! RENTEC_PASSWORD"

if defined MISSING (
    echo ERROR: Missing required values:%MISSING%
    echo Check config.ini and .env
    pause & exit /b 1
)

:: ── Start VcXsrv if not already running ─────────────────────────────────────
tasklist /FI "IMAGENAME eq vcxsrv.exe" 2>nul | find /i "vcxsrv.exe" >nul
if errorlevel 1 (
    echo Starting VcXsrv...
    start "" "%VCXSRV_EXE%" :0 -multiwindow -clipboard -wgl -ac -silent-dup-error
    timeout /t 3 /nobreak >nul
    echo VcXsrv ready.
) else (
    echo VcXsrv already running.
)

:: ── Connect and run login script ─────────────────────────────────────────────
echo.
echo Connecting to %VPS_USER%@%VPS_HOST%...
echo If a Cloudflare challenge appears, solve it in the browser window.
echo.

"%PLINK_EXE%" -X -ssh -pw "%VPS_PASSWORD%" %VPS_USER%@%VPS_HOST% ^
    "RENTEC_USERNAME=%RENTEC_USERNAME% RENTEC_PASSWORD=%RENTEC_PASSWORD% %VPS_SCRIPT_PATH%"

if errorlevel 1 (
    echo.
    echo ERROR: Script returned an error.
    echo If this is your first connection to this VPS, see the FIRST-TIME SETUP
    echo section in README or run the following to accept the host key:
    echo.
    echo   "%PLINK_EXE%" -ssh %VPS_USER%@%VPS_HOST%
    echo.
    pause & exit /b 1
)

echo.
echo Done. Session saved on VPS.
pause
