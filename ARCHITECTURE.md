# SignalScope System Architecture

SignalScope is an engineering-grade digital signal protocol decoder, timing analyzer, synthetic fault injection laboratory, and evidence-based root-cause diagnosis platform.

---

## 1. High-Level Architecture

SignalScope separates concerns across three decoupled tiers:

```
+-------------------------------------------------------------------------+
|                              Frontend                                    |
|   React 18 + TypeScript + Vite + Tailwind CSS + Plotly.js Waveform UI   |
+-------------------------------------------------------------------------+
                                    | (REST JSON API / HTTP)
                                    v
+-------------------------------------------------------------------------+
|                           Backend (Python)                              |
|           FastAPI + Pydantic + NumPy + SciPy + Pandas + SQLite          |
+-------------------------------------------------------------------------+
             |                                              |
             v                                              v
+-----------------------------+               +---------------------------+
|    C++17 Engine Adapter     |               |    Local Persistence      |
|  (Native pybind11 / C++ lib |               |  SQLite (Metadata/Runs)   |
|   or verified fallback)     |               |  NPZ Files (Waveforms)    |
+-----------------------------+               +---------------------------+
```

---

## 2. Signal Processing Engine (C++17 & Python Adapter)

Computational signal metrics are designed in a dedicated C++17 modular library located in `engine/`:

- `engine/include/signal_data.hpp`: Defines fundamental digital representations (`DigitalSignal`, `Transition`, `Pulse`, `ClockMetrics`, `TimingViolation`).
- `engine/src/transition_detector.cpp`: Vectorized edge transition extraction and pulse segmentation.
- `engine/src/signal_metrics.cpp`: Period jitter standard deviation, duty cycle calculations, and pulse width extrema.
- `engine/src/timing_analyzer.cpp`: Minimum/maximum pulse width verification and multi-channel setup/hold timing margin violation detection.
- `engine/tests/run_tests.cpp`: Standalone deterministic test harness.

### Python Engine Adapter (`app/services/cpp_engine_adapter.py`)
To maintain complete integrity across different deployment environments:
1. The adapter checks if the compiled native shared library (`.pyd` / `.so` / `.dll`) is present.
2. If compiled, it delegates computationally heavy operations directly to native C++.
3. If a native compiler is absent in the target environment (e.g., standard Windows workstation without Visual Studio C++ Build Tools), the adapter automatically invokes the verified Python fallback with 100% numerical and schema parity.
4. The system transparently exposes `engine_mode: "native_cpp"` or `engine_mode: "python_fallback"` in all health endpoints and diagnostic badges.

---

## 3. Data Flow

1. **Acquisition & Synthesis (`signal_generator.py`, `signal_importer.py`)**:
   - Simulated signals (UART, SPI, I2C, Clock, Pulses) or imported traces (.csv, .json, .vcd) are generated/parsed.
   - Large digital arrays are compressed and persisted as `.npz` files in `backend/data/waveforms/`.
   - Metadata, sample rate, duration, and channel topology are stored in SQLite (`signals` table).

2. **Protocol Decoding (`protocol_decoder.py`)**:
   - **UART Decoder**: Reconstructs baud frames, start/stop bit validation, and parity bit checks.
   - **SPI Decoder**: Reconstructs multi-byte transactions based on CPOL, CPHA, word length, and chip select.
   - **I2C Decoder**: Parses START/STOP conditions, 7-bit device addressing, read/write direction, and ACK/NACK status.
   - Decoders calculate a confidence classification (`VALID`, `WARNING`, `AMBIGUOUS`, `INVALID`, `INCOMPLETE`) and propose candidate alternative configurations when ambiguities occur.

3. **Timing Rule Analysis (`timing_analyzer.py`)**:
   - Evaluates configured hardware timing limits: setup margin, hold margin, minimum pulse duration, and clock jitter.
   - Emits structured `TimingViolation` records with rule IDs and exact timestamp evidence.

4. **Synthetic Fault Injection (`fault_injector.py`)**:
   - Injects controlled glitches, missing pulses, bit flips, jitter, or framing errors into a clean signal.
   - Preserves the pristine original trace, creating a new modified trace tagged with ground-truth fault intervals.

5. **Evidence-Based Root-Cause Analysis (`root_cause_engine.py`)**:
   - Applies deterministic rule logic correlating symptoms (framing error, coincident clock/data edges, unasserted chip select, NACK response) to physical causes.
   - Assigns calibrated confidence categories (`Strong evidence`, `Moderate evidence`, `Weak evidence`, `Insufficient evidence`).

6. **Automated Regression Runner (`regression_runner.py`)**:
   - Generates positive and negative test cases against independent mathematical oracles.
   - Executes assertions, measures per-test duration, and persists execution history in SQLite.

7. **Analysis Reports (`report_generator.py`)**:
   - Compiles server-side PDF documents via ReportLab or serializes JSON manifests.

---

## 4. Database Schema (SQLite)

- `sessions`: Session tracking and notes.
- `signals`: Signal metadata, channel names, sample rate, duration, and disk file pointers.
- `decodes`: Decoded packet frames, bytes, timestamps, and error annotations.
- `timing_analyses`: Calculated clock metrics and rule violation records.
- `faults`: Injected fault parameters and ground-truth intervals.
- `anomalies`: Rule-based and baseline-based anomaly findings.
- `diagnoses`: Ranked root-cause hypotheses with evidence strings.
- `test_cases`: Positive and negative test case definitions.
- `regression_runs`: Full test run history with pass rates and durations.
- `reports`: Metadata for generated PDF and JSON inspection reports.
