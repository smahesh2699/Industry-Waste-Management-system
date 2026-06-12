@echo off
title WasteLink Platform Launcher
color 0A
echo =================================================================
echo                 🌿 WasteLink Platform Launcher 🌿
echo =================================================================
echo.
echo This script will setup the database and start the web server.
echo.
echo -----------------------------------------------------------------
echo STEP 1: DATABASE INITIALIZATION
echo -----------------------------------------------------------------
echo.
set /p mysql_pass="Enter your MySQL 'root' password [Press Enter for 'root']: "
if "%mysql_pass%"=="" set mysql_pass=root

echo.
echo Locating MySQL installation...

:: Set default to absolute path we verified
set MYSQL_BIN="C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"

if exist %MYSQL_BIN% goto run_import
:: Fallback to default PATH command
set MYSQL_BIN=mysql

:run_import
echo Importing wastelink_schema.sql using %MYSQL_BIN%...
%MYSQL_BIN% -u root -p%mysql_pass% < database\wastelink_schema.sql
if errorlevel 1 goto db_error

echo.
echo [SUCCESS] Database wastelink_db created and seeded successfully!
goto start_server

:db_error
echo.
echo [WARNING] Database import failed. Make sure your password is correct.
echo (If you have already imported the database manually, you can ignore this).

:start_server
echo.
echo -----------------------------------------------------------------
echo STEP 2: STARTING JETTY SERVER
echo -----------------------------------------------------------------
echo.
echo Launching the server on port 8080. Please wait...
echo Once started, open http://localhost:8080 in your browser.
echo.
echo To stop the server at any time, press Ctrl+C in this window.
echo -----------------------------------------------------------------
echo.

call mvn jetty:run
pause
