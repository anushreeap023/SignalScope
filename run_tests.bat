@echo off
echo ========================================================
echo   Running SignalScope Automated Test Suites
echo ========================================================
cd /d "%~dp0"

if exist "D:\python311\python.exe" (
    set PY_EXE=D:\python311\python.exe
) else (
    set PY_EXE=python
)

echo [1/2] Running Backend Pytest Suite...
cd "%~dp0backend"
set PYTHONPATH=%cd%
"%PY_EXE%" -m pytest tests/test_backend.py -v
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Backend tests failed.
    exit /b 1
)

echo.
echo [2/2] Running Frontend Vitest Suite...
cd "%~dp0frontend"
call npm run test
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Frontend tests failed.
    exit /b 1
)

echo.
echo ========================================================
echo   ALL SIGNAL SCOPE AUTOMATED TESTS PASSED!
echo ========================================================
pause
