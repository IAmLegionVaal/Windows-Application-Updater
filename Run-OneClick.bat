@echo off
setlocal
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0Update-WindowsApplications.ps1" -Upgrade
set "RC=%ERRORLEVEL%"
echo.
echo Windows Application Updater finished with exit code %RC%.
pause
exit /b %RC%
