@echo off
echo ============================================
echo   Lexi - Upload to Firestore
echo ============================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Python not installed!
    echo Download from: https://www.python.org/downloads/
    pause
    exit /b 1
)

REM Check if firebase-admin is installed
python -c "import firebase_admin" >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [INFO] Installing firebase-admin...
    pip install firebase-admin
)

REM Check if Firebase CLI is installed
firebase --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Firebase CLI not installed!
    echo Install it with: npm install -g firebase-tools
    pause
    exit /b 1
)

REM Check if logged in
firebase login:list >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [INFO] Please login to Firebase first...
    firebase login
)

echo.
echo [OK] Starting upload...
python scripts/upload_to_firestore.py

echo.
pause
