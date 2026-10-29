@echo off
echo ========================================================
echo   Starting SignalScope Backend Server (FastAPI)
echo ========================================================
cd /d "%~dp0backend"
set PYTHONPATH=%cd%

if exist "D:\python311\python.exe" (
    set PY_EXE=D:\python311\python.exe
) else (
    set PY_EXE=python
)

echo Using Python: %PY_EXE%
echo Starting Uvicorn at http://127.0.0.1:8000 ...
"%PY_EXE%" -m uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload
pause
