@echo off
echo ========================================================
echo   Launching SignalScope Full-Stack Platform
echo ========================================================

echo Starting Backend Server on http://127.0.0.1:8000 ...
start "SignalScope Backend (FastAPI)" cmd /c "%~dp0start_backend.bat"

echo Waiting 2 seconds for backend initialization...
timeout /t 2 /nobreak >nul

echo Starting Frontend Dev Server on http://localhost:3000 ...
start "SignalScope Frontend (Vite)" cmd /c "%~dp0start_frontend.bat"

echo.
echo SignalScope is starting up!
echo Frontend: http://localhost:3000
echo Backend API Docs: http://127.0.0.1:8000/docs
echo.
pause
