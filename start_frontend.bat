@echo off
echo ========================================================
echo   Starting SignalScope Frontend Application (Vite + React)
echo ========================================================
cd /d "%~dp0frontend"
echo Running frontend on http://localhost:3000 ...
npm run dev
pause
