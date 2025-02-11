@echo off
setlocal

:: Read the PHP path from php_version.txt
set PHP_PATH=
if exist "%USERPROFILE%\php_version.txt" (
    set /p PHP_PATH=<"%USERPROFILE%\php_version.txt"
) else (
    echo No PHP version set. Use 'setphp' to select one.
    exit /b 1
)

:: Extract PHP version number directly from the file (e.g., 81, 82, 83, 84)
for /f "tokens=*" %%A in ('echo %PHP_PATH% ^| findstr /r "[0-9]\.[0-9]"') do (
    set "PHP_VER=%%A"
)
set "PHP_VER=%PHP_VER:.=%"

:: Debugging output (optional)
echo Debug: PHP_VER=%PHP_VER%

:: Define paths for php.ini and ext folder
set INI_PATH=C:\php\php%PHP_VER%.ini
set EXT_PATH=C:\php\ext%PHP_VER%

:: Ensure the php.ini file exists
if not exist "%INI_PATH%" (
    echo Warning: php.ini not found at %INI_PATH%. Using default settings.
)

:: Ensure the extensions folder exists
if not exist "%EXT_PATH%" (
    echo Warning: Extension folder not found at %EXT_PATH%. Some modules may not load.
)

:: Run PHP with the specific ini file and ext folder
"%PHP_PATH%" -c "%INI_PATH%" -d extension_dir="%EXT_PATH%" %*
