@echo off
setlocal DisableDelayedExpansion
echo =======================================================
echo Airline Reservation System Setup (Fixed)
echo =======================================================
echo.

set "MYSQL_URL="
for /d %%G in ("C:\Program Files\MySQL\MySQL Server *") do (
    if EXIST "%%G\bin\mysql.exe" set "MYSQL_URL=%%G\bin\mysql.exe"
)

if "%MYSQL_URL%"=="" (
    for /f "tags=1 skip=1 delims=" %%G IN ('wmic Process Where "Name='mysqld.exe'" Get ExecutablePath ^| find "\" 2^>nul') Do (
        set "MYSQLD=%%~G"
    )
    if defined MYSQLD (
        for %%I in ("%MYSQLD%") do set "BINDIR=%%~dpI"
        set "MYSQL_URL=!BINDIR!mysql.exe"
    )
)

if "%MYSQL_URL%"=="" (
   rem Fallback Search via Where
   for /f "delims=" %%i in ('where mysql 2^>nul') do set "MYSQL_URL=%%i"
)

if "%MYSQL_URL%"=="" (
    echo [ERROR] Could not find mysql.exe anywhere! 
    echo Ensure MySQL Server is actually installed!
    pause
    exit /b 1
)

echo Enter your MySQL Username (default: root):
set /P MYSQLUSER=
if "%MYSQL_USER%"=="" set MYSQL_USER=root
echo.
echo Executing MySQL From: "%MYSQL_URL%"
echo Please enter your password when prompted!
echo.

"%MYSQL_URL%" -u "%MYSQL_USER%" -p -t < full_setup.sql

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Script execution failed!
    echo Ensure MySQL is running and your credentials are correct.
) else (
    echo.
    echo [SUCCESS] Database setup and reporting complete.
)

echo.
pause
