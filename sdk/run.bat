@echo off
REM ===============================
REM One-click JPEG Encoder Flow
REM ===============================

REM Step 1: Run Python data input generator
echo 🔹 Running data_in.py ...
python script\data_in.py
if %errorlevel% neq 0 (
    echo ❌ Error running data_in.py
    pause
    exit /b %errorlevel%
)

REM Step 2: Run QuestaSim simulation
echo 🔹 Running QuestaSim simulation ...
vsim -c -do "do run.do; quit"
if %errorlevel% neq 0 (
    echo ❌ Error running QuestaSim simulation
    pause
    exit /b %errorlevel%
)

REM Step 3: Generate final image from bitstream
echo 🔹 Generating JPEG image ...
python raw_jpeg_bitstream_to_image\jpeg.py
if %errorlevel% neq 0 (
    echo ❌ Error running jpeg.py
    pause
    exit /b %errorlevel%
)

echo ✅ All steps completed successfully!
pause
