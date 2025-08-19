@echo off
setlocal

REM ================================
REM Paths (relative to repo root)
REM ================================
set PYTHON=python
set REPO_ROOT=%~dp0
set SCRIPT_DIR=%REPO_ROOT%script
set RTL_DIR=%REPO_ROOT%rtl
set TEST_IMAGE=%SCRIPT_DIR%\test.jpg
set TB_TOP=jpeg_top_TB

REM QuestaSim commands
set VLOG=vlog
set VSIM=vsim -c

echo ===============================================
echo Step 1: Preprocess the test image
echo ===============================================
%PYTHON% "%SCRIPT_DIR%\for_all.py" "%TEST_IMAGE%"
if errorlevel 1 (
    echo ❌ ERROR: Python preprocessing failed
    pause
    exit /b 1
)

echo ===============================================
echo Step 2: Compile RTL + Testbench
echo ===============================================
cd /d "%RTL_DIR%"
%VLOG% -sv *.sv
if errorlevel 1 (
    echo ❌ ERROR: Compilation failed
    pause
    exit /b 1
)

echo ===============================================
echo Step 3: Run Simulation
echo ===============================================
%VSIM% %TB_TOP% -do "run 100ms; quit -f"
if errorlevel 1 (
    echo ❌ ERROR: Simulation failed
    pause
    exit /b 1
)

echo ===============================================
echo Step 4: Convert output hex to JPEG
echo ===============================================
%PYTHON% "%SCRIPT_DIR%\for_all_hex_to_jpg.py" "%SCRIPT_DIR%\jpeg_output.hex" "%SCRIPT_DIR%\output.jpg"
if errorlevel 1 (
    echo ❌ ERROR: JPEG rebuild failed
    pause
    exit /b 1
)

echo ===============================================
echo ✅ All steps completed successfully!
echo Output image: %SCRIPT_DIR%\output.jpg
echo ===============================================

pause
