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

:: Define paths
set "INI_DEV=%PHP_BASE_DIR%php.ini-development"
set "INI_PROD=%PHP_BASE_DIR%php.ini-production"
set "CENTRAL_DIR=C:\php\%PHP_VERSION%"
set "CENTRAL_INI=%CENTRAL_DIR%\php.ini"
set "CENTRAL_EXT=%CENTRAL_DIR%\ext"

:: Create centralized directory if it doesn't exist
if not exist "%CENTRAL_DIR%" (
    mkdir "%CENTRAL_DIR%" 2>nul
    if errorlevel 1 (
        echo Error: Failed to create directory %CENTRAL_DIR%
        exit /b 1
    )
)

:: Create ext directory if it doesn't exist
if not exist "%CENTRAL_EXT%" (
    mkdir "%CENTRAL_EXT%" 2>nul
    if exist "%PHP_BASE_DIR%ext" (
        echo Copying extensions to centralized location...
        xcopy /E /I /Y "%PHP_BASE_DIR%ext" "%CENTRAL_EXT%" >nul
    )
)

:: Validate template files exist
if not exist "%INI_DEV%" (
    echo Error: Development template not found at: %INI_DEV%
    exit /b 1
)
if not exist "%INI_PROD%" (
    echo Error: Production template not found at: %INI_PROD%
    exit /b 1
)

echo ====================================
echo PHP INI Configuration Setup
echo ====================================
echo Current PHP Version: %PHP_VERSION%
echo.

:: Check if php.ini already exists
if exist "%CENTRAL_INI%" (
    echo A php.ini file already exists at:
    echo %CENTRAL_INI%
    echo.
    echo What would you like to do?
    echo 1^) Backup existing and create new from development
    echo 2^) Backup existing and create new from production
    echo 3^) Edit existing php.ini
    echo 4^) Exit
    choice /c 1234 /n /m "Choose an option (1-4): "
    if errorlevel 4 goto :end
    if errorlevel 3 goto :edit_ini
    if errorlevel 2 goto :copy_prod
    if errorlevel 1 goto :copy_dev
) else (
    echo No php.ini found. Choose a template:
    echo 1^) Create from development ^(Recommended for local development^)
    echo 2^) Create from production
    echo 3^) Exit
    choice /c 123 /n /m "Choose an option (1-3): "
    if errorlevel 3 goto :end
    if errorlevel 2 goto :copy_prod
    if errorlevel 1 goto :copy_dev
)

:copy_dev
if exist "%CENTRAL_INI%" (
    echo Creating backup of existing php.ini...
    copy "%CENTRAL_INI%" "%CENTRAL_INI%.backup" >nul
)

echo Copying development configuration...
copy "%INI_DEV%" "%CENTRAL_INI%" >nul
if errorlevel 1 (
    echo Error: Failed to copy development configuration
    exit /b 1
)

echo Successfully created php.ini from development template!
echo Location: %CENTRAL_INI%
goto :edit_prompt

:copy_prod
if exist "%CENTRAL_INI%" (
    echo Creating backup of existing php.ini...
    copy "%CENTRAL_INI%" "%CENTRAL_INI%.backup" >nul
)

echo Copying production configuration...
copy "%INI_PROD%" "%CENTRAL_INI%" >nul
if errorlevel 1 (
    echo Error: Failed to copy production configuration
    exit /b 1
)

echo Successfully created php.ini from production template!
echo Location: %CENTRAL_INI%
goto :edit_prompt

:edit_prompt
echo.
choice /c YN /n /m "Would you like to edit the php.ini file now? (Y/N): "
if errorlevel 2 goto :end
if errorlevel 1 goto :edit_ini

:edit_ini
:: Try to use VS Code first, then notepad++, then default notepad
where code >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo Opening php.ini with Visual Studio Code...
    start /b "" code "%CENTRAL_INI%" >nul 2>&1
    goto :end
)

where notepad++ >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo Opening php.ini with Notepad++...
    start /b "" notepad++ "%CENTRAL_INI%" >nul 2>&1
    goto :end
)

echo Opening php.ini with Notepad...
start /b "" notepad "%CENTRAL_INI%" >nul 2>&1

:end
endlocal