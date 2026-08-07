@echo off
echo ============================================
echo   Lexi - Upload Data to Firestore
echo ============================================
echo.

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
    echo [ERROR] Not logged in to Firebase!
    echo Run: firebase login
    pause
    exit /b 1
)

echo [1/4] Initializing Firebase in project...
firebase init firestore --project=lexi-language-app

echo.
echo [2/4] Uploading curriculum data...
firebase firestore:write /curriculum/a1 "@assets/data/curriculum_a1.json"

echo.
echo [3/4] Uploading question bank...
firebase firestore:write /questions/a1 "@assets/data/questions_a1.json"

echo.
echo [4/4] Deploying Firestore rules...
firebase deploy --only firestore:rules

echo.
echo ============================================
echo   Done! Data uploaded to Firestore.
echo ============================================
pause
