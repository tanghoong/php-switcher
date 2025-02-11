@echo off
if "%1"=="" (
    echo Usage: phpset [81|82|83|84]
    exit /b 1
)

:: Insert a dot between the major and minor version (e.g., 84 -> 8.4)
set PHP_VERSION=8.%1

:: Construct the PHP path dynamically
set PHP_PATH=C:\Users\Developer\AppData\Local\Microsoft\WinGet\Packages\PHP.PHP.%PHP_VERSION%_Microsoft.Winget.Source_8wekyb3d8bbwe\php.exe

:: Check if the PHP executable exists before setting it
if exist "%PHP_PATH%" (
    echo %PHP_PATH% > "%USERPROFILE%\php_version.txt"
    echo PHP version switched to %PHP_VERSION%
) else (
    echo Error: PHP version %PHP_VERSION% not found!
)
