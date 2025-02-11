@echo off
setlocal EnableDelayedExpansion

:: Read the PHP path from php_version.txt
set PHP_PATH=
if exist "%USERPROFILE%\php_version.txt" (
    set /p PHP_PATH=<"%USERPROFILE%\php_version.txt"
) else (
    echo No PHP version set. Use 'phpset' to select one.
    exit /b 1
)

echo ====================================
echo PHP Configuration Information
echo ====================================
echo.

:: Get PHP version
for /f "tokens=* usebackq" %%a in (`"%PHP_PATH%" -v ^| findstr /r "PHP [0-9]"`) do (
    echo PHP Version: %%a
    echo.
)

:: Get loaded configuration file
echo Loaded Configuration File:
"%PHP_PATH%" --ini | findstr /i "configuration"
echo.

:: Get additional .ini files
echo Additional .ini Files Loaded:
"%PHP_PATH%" --ini | findstr /i "additional"
echo.

:: Get scan directory
echo Scan Directory for additional .ini files:
"%PHP_PATH%" --ini | findstr /i "scan"
echo.

:: Display extension directory
for /f "tokens=* usebackq" %%a in (`"%PHP_PATH%" -i ^| findstr /i "extension_dir"`) do (
    echo Extension Directory: %%a
)
echo.

:: Ask if user wants to see full configuration
echo Would you like to see the full PHP configuration? (Y/N)
choice /c YN /n
if errorlevel 2 goto :end
if errorlevel 1 (
    echo.
    echo ====================================
    echo Full PHP Configuration
    echo ====================================
    echo.
    "%PHP_PATH%" -i
)

:end
endlocal 