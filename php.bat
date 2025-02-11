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

:: Extract base directory from PHP_PATH
for %%i in ("%PHP_PATH%") do set "PHP_BASE_DIR=%%~dpi"

:: Define paths for centralized locations
set "CENTRAL_DIR=C:\php\%PHP_VERSION%"
set "CENTRAL_INI=%CENTRAL_DIR%\php.ini"
set "CENTRAL_EXT=%CENTRAL_DIR%\ext"

:: If centralized directory doesn't exist, create it and copy files
if not exist "%CENTRAL_DIR%" (
    echo Creating centralized PHP directory...
    mkdir "%CENTRAL_DIR%" 2>nul
    
    :: Copy extensions
    if exist "%PHP_BASE_DIR%ext" (
        echo Copying extensions to centralized location...
        xcopy /E /I /Y "%PHP_BASE_DIR%ext" "%CENTRAL_EXT%" >nul
    )
    
    :: Copy php.ini if it exists
    if exist "%PHP_BASE_DIR%php.ini" (
        echo Copying php.ini to centralized location...
        copy /Y "%PHP_BASE_DIR%php.ini" "%CENTRAL_INI%" >nul
    ) else if exist "%PHP_BASE_DIR%php.ini-development" (
        echo Creating php.ini from development template...
        copy /Y "%PHP_BASE_DIR%php.ini-development" "%CENTRAL_INI%" >nul
    )
)

:: Show configuration info
echo PHP Configuration:
echo - Version: %PHP_VERSION%
echo - Base Dir: %PHP_BASE_DIR%
echo - Central Dir: %CENTRAL_DIR%

:: Check and display extension directory status
if exist "%CENTRAL_EXT%" (
    echo - Using Extensions: %CENTRAL_EXT%
    set "EXT_DIR=%CENTRAL_EXT%"
) else (
    echo - Warning: Extension directory not found
    echo - Falling back to original location: %PHP_BASE_DIR%ext
    set "EXT_DIR=%PHP_BASE_DIR%ext"
)

:: Check and display INI file status
if exist "%CENTRAL_INI%" (
    echo - Using INI: %CENTRAL_INI%
    set "PHP_INI=%CENTRAL_INI%"
) else (
    echo - Warning: No php.ini found in centralized location
    if exist "%PHP_BASE_DIR%php.ini" (
        echo - Falling back to original location: %PHP_BASE_DIR%php.ini
        set "PHP_INI=%PHP_BASE_DIR%php.ini"
    ) else (
        echo - Warning: No php.ini found, using default settings
        set "PHP_INI="
    )
)
echo.

:: Run PHP with the appropriate configuration
if defined PHP_INI (
    "%PHP_PATH%" -n -c "%PHP_INI%" -d extension_dir="%EXT_DIR%" %*
) else (
    "%PHP_PATH%" -d extension_dir="%EXT_DIR%" %*
)

endlocal
