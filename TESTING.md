# SignalScope Testing & Verification Guide

This document describes the automated test suites, manual verification workflows, and testing principles implemented in SignalScope.

---

## 1. Automated Test Suites

SignalScope contains three independent testing layers:

### A. Backend Pytest Suite (`backend/tests/test_backend.py`)
Tests computational correctness across all core modules:
1. `test_signal_generation_clock`: Validates periodic square wave generation and sample rate accuracy.
2. `test_uart_encode_and_decode`: Verifies 115200 8N1 UART synthesis and zero-error decoding.
3. `test_spi_encode_and_decode`: Verifies SPI Mode 0 clock edge alignment and MOSI payload recovery.
4. `test_i2c_encode_and_decode`: Verifies I2C START/STOP conditions, 7-bit addressing, and ACK bits.
5. `test_timing_analyzer_frequency_measurement`: Validates exact frequency and duty cycle calculation.
6. `test_fault_injection_and_detection`: Verifies ground-truth tagging and sample-level difference calculations.
7. `test_regression_runner_execution`: Verifies automated test suite generation and assertion execution.
8. `test_report_generation_json_and_pdf`: Verifies server-side PDF and JSON report compilation.

**Running Backend Tests:**
```powershell
cd backend
$env:PYTHONPATH = (Get-Location).Path
python -m pytest tests/test_backend.py -v
```

### B. Frontend Vitest Suite (`frontend/src/test/App.test.tsx`)
Tests React component rendering and UI logic:
- `StatusBadge` rendering for all status variants (`VALID`, `WARNING`, `FAIL`).
- `EmptyState` rendering and callback invocation.
- Navigation layout and responsive toolbar controls.

**Running Frontend Tests:**
```powershell
cd frontend
npm run test
```

### C. C++ Engine Unit Test Runner (`engine/tests/run_tests.cpp`)
Unit tests written in C++17 validating numeric precision:
- `test_transition_detection`: Edge identification against known samples.
- `test_clock_metrics`: Exact 100 kHz clock period and duty cycle validation.
- `test_timing_analyzer`: Sub-microsecond glitch violation detection.

**Compiling and Running C++ Engine Tests (when MSVC/GCC is available):**
```powershell
cd engine
cmake -B build -S .
cmake --build build --config Release
.\build\Release\test_engine.exe
```

---

## 2. Integrated Regression Runner (Module 10)

SignalScope includes an in-app automated regression runner accessible from the sidebar (`/regression`).
- Generates positive and negative test cases against independent mathematical oracles.
- Executes assertions against decoders.
- Records test duration, status (`PASS` or `FAIL`), and failure details in SQLite.
- Tracks historical runs and pass rates over time.

---

## 3. End-to-End Verification Checklist

| Step | Action | Expected Outcome |
|------|--------|------------------|
| 1 | Launch `start_all.bat` | Backend starts on 8000, Frontend starts on 3000 |
| 2 | Open `http://localhost:3000` | Engineering dashboard displays with active engine mode |
| 3 | Navigate to Signal Lab | Generate UART trace; Plotly viewer displays square waves |
| 4 | Place Cursor A and Cursor B | Delta t and frequency are displayed accurately |
| 5 | Navigate to Protocol Decoder | Decode UART; table shows valid frames and ASCII bytes |
| 6 | Navigate to Timing Analysis | Run analysis; frequency, duty cycle, and violations display |
| 7 | Navigate to Fault Injection Lab | Inject 'extra_pulse'; diff viewer highlights divergent samples |
| 8 | Navigate to Root-Cause Analysis | Ranked hypothesis displays supporting evidence |
| 9 | Navigate to Regression Testing | Execute suite; pass rate and assertions display |
| 10 | Navigate to Reports | Generate PDF report and download verified document |
