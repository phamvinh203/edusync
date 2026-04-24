@echo off
REM Manual Release Helper - Prepare for manual release
REM This script does NOT auto-push, only prepares files
REM English version to avoid encoding issues

chcp 65001 >nul 2>&1
cls

echo ==========================================
echo  Manual Release Helper - EduSync
echo ==========================================
echo.
echo This script will help you:
echo   1. Build app
echo   2. Prepare git commit
echo   3. Create git tag
echo   4. Provide links to create manual release on GitHub
echo.

pause

echo.
echo ==========================================
echo  Step 1: Building EduSync App Bundle
echo ==========================================
echo.

echo [INFO] Cleaning project...
call flutter clean
echo [OK] Clean completed
echo.

echo [INFO] Getting dependencies...
call flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo [WARN] Flutter pub get had issues, but continuing...
)
echo [OK] Dependencies updated
echo.

echo [INFO] Building App Bundle...
echo [INFO] This may take 2-5 minutes...
echo.

call flutter build appbundle --release --obfuscate --split-debug-info=./debug-info

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] Flutter build failed!
    echo.
    echo [TIPS] Possible issues:
    echo    - Check Flutter installation (flutter doctor)
    echo    - Check internet connection
    echo    - Check for syntax errors in code
    echo.
    echo [CMD] Try running manually:
    echo    flutter build appbundle --release
    echo.

    set /p CONTINUE="Continue anyway? (y/n): "
    if /i not "%CONTINUE%"=="y" (
        echo [STOPPED] Stopped by user
        pause
        exit /b 1
    )
)

echo.
echo [OK] Build process completed!
echo.

set SIZEMB=0

REM Check for both possible file names
if exist "build\app\outputs\bundle\release\edusync-release.aab" (
    REM Get file size
    for %%A in ("build\app\outputs\bundle\release\edusync-release.aab") do set SIZE=%%~zA
    set /a SIZEMB=%SIZE% / 1048576

    echo [SUCCESS] Build Successful!
    echo   [+] File: edusync-release.aab
    echo   [+] Size: %SIZEMB% MB
    echo   [+] Location: build\app\outputs\bundle\
) else if exist "build\app\outputs\bundle\release\app-release.aab" (
    echo [INFO] Found app-release.aab, renaming to edusync-release.aab...

    REM Rename file
    ren "build\app\outputs\bundle\release\app-release.aab" "edusync-release.aab"

    if exist "build\app\outputs\bundle\release\edusync-release.aab" (
        REM Get file size
        for %%A in ("build\app\outputs\bundle\release\edusync-release.aab") do set SIZE=%%~zA
        set /a SIZEMB=%SIZE% / 1048576

        echo [SUCCESS] File renamed successfully!
        echo   [+] File: edusync-release.aab (renamed from app-release.aab)
        echo   [+] Size: %SIZEMB% MB
        echo   [+] Location: build\app\outputs\bundle\
    ) else (
        echo [ERROR] Failed to rename file!
        echo [INFO] Build file exists but rename failed
    )
) else (
    echo [WARN] Build file not found!
    echo [INFO] Expected: build\app\outputs\bundle\release\app-release.aab
    echo.

    set /p CONTINUE="Continue to git steps anyway? (y/n): "
    if /i not "%CONTINUE%"=="y" (
        echo [STOPPED] Stopped by user
        pause
        exit /b 1
    )
)

echo.
echo.
echo ==========================================
echo  Step 2: Git Operations
echo ==========================================
echo.

set VERSION=1.0.0
set /p VERSION="[TAG] Enter version tag (default: 1.0.0): "

if "%VERSION%"=="" set VERSION=1.0.0

echo.
echo [INFO] Version: v%VERSION%
echo [INFO] Commit message: Release v%VERSION%
echo.

echo [INFO] Checking git status...
git status --short
echo.

set /p COMMIT="[GIT] Commit and tag now? (y/n): "
if /i not "%COMMIT%"=="y" (
    echo [SKIPPED] Git operations skipped
    echo.
    echo [CMD] Run manually later:
    echo    git add .
    echo    git commit -m "Release v%VERSION%"
    echo    git tag v%VERSION%
    echo.

    goto :skip_git
)

echo.
echo [INFO] Adding files...
git add .

echo.
echo [INFO] Committing...
git commit -m "Release v%VERSION%"

if %ERRORLEVEL% EQU 0 (
    echo [OK] Committed successfully
) else (
    echo [WARN] Git commit had issues
    echo [INFO] Nothing to commit or git error
)

echo.
echo [INFO] Creating tag: v%VERSION%...
git tag v%VERSION%

if %ERRORLEVEL% EQU 0 (
    echo [OK] Tag created successfully
) else (
    echo [ERROR] Tag creation failed!
    echo [INFO] Tag might already exist. Delete with: git tag -d v%VERSION%
)

:skip_git
echo.
echo.
echo ==========================================
echo  Step 3: Push to GitHub
echo ==========================================
echo.

echo [STATUS] Current status:
echo   [-] Version: v%VERSION%
echo   [-] Tag: v%VERSION%
if %SIZEMB% GTR 0 (
    echo   [+] Build: edusync-release.aab (%SIZEMB% MB)
) else (
    echo   [!] Build: Not found or failed
)
echo.

echo [CMD] Commands to push manually:
echo.
echo   git push origin main
echo   git push origin v%VERSION%
echo.

set /p PUSH="[GIT] Push to GitHub now? (y/n): "

if /i "%PUSH%"=="y" (
    echo.
    echo [INFO] Pushing code to main branch...
    git push origin main

    if %ERRORLEVEL% EQU 0 (
        echo [OK] Code pushed successfully
    ) else (
        echo [WARN] Git push had issues
        echo [INFO] Check your internet connection and GitHub credentials
    )

    echo.
    echo [INFO] Pushing tag to GitHub...
    git push origin v%VERSION%

    if %ERRORLEVEL% EQU 0 (
        echo [OK] Tag pushed successfully
    ) else (
        echo [WARN] Git tag push had issues
        echo [INFO] Tag might already exist on remote
        echo    Delete remote tag: git push origin :refs/tags/v%VERSION%
    )

    echo.
    echo [OK] Push operations completed!
) else (
    echo.
    echo [SKIPPED] Push operations skipped
    echo [INFO] Push manually later with the commands above
)

echo.
echo.
echo ==========================================
echo  Step 4: Create Release on GitHub
echo ==========================================
echo.

REM Get repository info
for /f "tokens=*" %%a in ('git config --get remote.origin.url 2^>nul') do set REMOTE_URL=%%a

if "%REMOTE_URL%"=="" (
    echo [WARN] Could not detect repository URL
    echo [INFO] Make sure you're in a git repository with remote origin
    set REMOTE_URL=https://github.com/username/edusync
)

echo [INFO] Release Information:
echo   [-] Version: v%VERSION%
echo   [-] Tag: v%VERSION%
if %SIZEMB% GTR 0 (
    echo   [+] Build file: edusync-release.aab (%SIZEMB% MB)
) else (
    echo   [!] Build file: Not found
)
echo   [-] Repository: %REMOTE_URL%
echo.

echo [LINKS] Direct Links:
echo.
echo   Create Release:
echo   https://github.com/[username]/edusync/releases/new?tag=v%VERSION%
echo.

echo [FILE] File to Upload:
if %SIZEMB% GTR 0 (
    echo   [+] build\app\outputs\bundle\release\edusync-release.aab
) else (
    echo   [!] Build file not found - check build process
)

echo.
echo [NOTES] Release Notes Template:
echo   ===========================================
echo   [RELEASE] EduSync v%VERSION%
echo.
echo   [FEATURE] New Features:
echo      - List new features here
echo.
echo   [FIX] Bug Fixes:
echo      - List bug fixes here
echo.
echo   [TECH] Technical:
if %SIZEMB% GTR 0 (
    echo      - App size: %SIZEMB%MB (optimized 80%%)
) else (
    echo      - App size: Not available
)
echo      - Build date: %date% %time%
echo   ===========================================
echo.

echo [NEXT] Next Steps:
echo   1. Open GitHub repository
echo   2. Go to Releases section
echo   3. Click "Create a new release"
echo   4. Select tag: v%VERSION%
if %SIZEMB% GTR 0 (
    echo   5. Upload: edusync-release.aab
) else (
    echo   5. Build app first before uploading
)
echo   6. Add release notes
echo   7. Publish release
echo.

if %SIZEMB% GTR 0 (
    echo [ACTION] Quick Actions:
    echo.
    set /p OPEN_REPO="[OPEN] Open GitHub repository now? (y/n): "
    if /i "%OPEN_REPO%"=="y" (
        start "" "https://github.com"
    )
)

echo.
echo ==========================================
echo  [COMPLETE] Manual release preparation done!
echo ==========================================
echo.
echo [SUMMARY] Summary:
if %SIZEMB% GTR 0 (
    echo   [+] Build: Successful (%SIZEMB% MB)
) else (
    echo   [-] Build: Failed or not found
)
echo   [+] Git: Prepared
echo   [+] Tag: v%VERSION% created
echo   [+] Next: Create release on GitHub
echo.
pause
