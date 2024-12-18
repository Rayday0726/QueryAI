@echo off
echo Starting SQL Assistant...

:: Set the working directory to the script's location
cd /d "%~dp0"

:: Start the backend
echo Starting backend service...
start /B "" "sql_assistant_backend.exe"

:: Wait for backend to initialize
echo Initializing...
timeout /t 2 /nobreak > nul

:: Start the frontend
echo Launching application...
start "" "frontend.exe"

exit