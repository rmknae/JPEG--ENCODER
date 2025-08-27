@echo off
REM ===============================
REM One-click JPEG Encoder Flow
REM ===============================

echo 🔹 Starting JPEG Encoder Flow ...
python script\data_in.py

if %errorlevel% neq 0 (
    echo ❌ Error occurred!
    pause
    exit /b %errorlevel%
)

echo ✅ All steps completed successfully!
pause
