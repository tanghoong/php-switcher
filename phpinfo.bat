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

:: Extract PHP version from path
for /f "tokens=3,4 delims=." %%a in ('echo %PHP_PATH% ^| findstr /r "PHP\.PHP\.[0-9]\.[0-9]"') do (
    set "PHP_VERSION=%%a.%%b"
    set "PHP_VERSION=!PHP_VERSION:_=!"
)

:: Define paths for centralized locations
set "CENTRAL_DIR=C:\php\%PHP_VERSION%"
set "CENTRAL_INI=%CENTRAL_DIR%\php.ini"
set "CENTRAL_EXT=%CENTRAL_DIR%\ext"

:: Create temporary directory if it doesn't exist
set "TEMP_DIR=%TEMP%\phpinfo"
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

:: Create PHP file with phpinfo
set "PHP_FILE=%TEMP_DIR%\phpinfo.php"
echo ^<?php phpinfo^(^)^; ?^> > "%PHP_FILE%"

:: Find an available port (starting from 8000)
set PORT=8000
:findPort
netstat -an | find ":%PORT%" > nul
if %ERRORLEVEL% EQU 0 (
    set /a PORT+=1
    goto findPort
)

echo ====================================
echo PHP Configuration Viewer
echo ====================================
echo.
echo Starting PHP built-in server on port %PORT%...

:: Start PHP built-in server in background with centralized configuration
if exist "%CENTRAL_INI%" (
    start /b cmd /c ""%PHP_PATH%" -n -c "%CENTRAL_INI%" -d extension_dir="%CENTRAL_EXT%" -S localhost:%PORT% -t "%TEMP_DIR%" >nul 2>&1"
) else (
    echo Warning: No centralized php.ini found at %CENTRAL_INI%
    start /b cmd /c ""%PHP_PATH%" -S localhost:%PORT% -t "%TEMP_DIR%" >nul 2>&1"
)

:: Wait a moment for the server to start
timeout /t 1 /nobreak >nul

:: Open default browser
echo Opening browser...
start http://localhost:%PORT%/phpinfo.php

echo.
echo Server is running. Press any key to stop the server and clean up.
pause >nul

:: Kill PHP server process
for /f "tokens=5" %%a in ('netstat -aon ^| find ":%PORT%"') do (
    taskkill /F /PID %%a >nul 2>&1
)

:: Clean up temporary files
del "%PHP_FILE%" >nul 2>&1
rmdir "%TEMP_DIR%" >nul 2>&1

echo Server stopped and temporary files cleaned up.

endlocal 