@echo off
setlocal enabledelayedexpansion

echo.
echo ===============================================
echo   Wisme Research App - Batch Fix Script
echo ===============================================
echo.

cd /d "d:\Startups\Wisme\Development\Wisme_ResearchApp2\researchapp2"

echo Current directory: %CD%
echo.

echo 1. Fixing pubspec.yaml name field...
if exist "pubspec.yaml" (
    powershell -Command "(Get-Content 'pubspec.yaml' -Raw) -replace 'name: researchapp2', 'name: wisme_research_app' | Set-Content 'pubspec.yaml' -NoNewline"
    echo    ✓ Fixed pubspec.yaml
) else (
    echo    ! pubspec.yaml not found
)

echo.
echo 2. Fixing withOpacity issues in journey_episodes_overview_screen.dart...
if exist "lib\journeys\journey_episodes_overview_screen.dart" (
    powershell -Command "$file = 'lib\journeys\journey_episodes_overview_screen.dart'; $content = Get-Content $file -Raw; $content = $content -replace '\.withOpacity\(0\.1\)', '.withValues(alpha: 0.1)'; $content = $content -replace '\.withOpacity\(0\.2\)', '.withValues(alpha: 0.2)'; $content = $content -replace '\.withOpacity\(0\.3\)', '.withValues(alpha: 0.3)'; $content = $content -replace '\.withOpacity\(0\.4\)', '.withValues(alpha: 0.4)'; $content = $content -replace '\.withOpacity\(0\.5\)', '.withValues(alpha: 0.5)'; Set-Content $file -Value $content -NoNewline"
    echo    ✓ Fixed journey episodes overview screen
) else (
    echo    ! journey_episodes_overview_screen.dart not found
)

echo.
echo 3. Fixing print statements in main.dart...
if exist "lib\main.dart" (
    powershell -Command "$file = 'lib\main.dart'; $content = Get-Content $file -Raw; if ($content -notmatch 'import.*foundation.dart') { $content = $content -replace '(import.*material.dart.*;)', '$1`nimport ''package:flutter/foundation.dart'';' }; $content = $content -replace 'print\(', 'debugPrint('; Set-Content $file -Value $content -NoNewline"
    echo    ✓ Fixed main.dart print statements
) else (
    echo    ! main.dart not found
)

echo.
echo 4. Running Flutter pub get...
flutter pub get

echo.
echo 5. Running Flutter analyze to check progress...
flutter analyze --no-fatal-infos > analyze_result.txt 2>&1
findstr "issues found" analyze_result.txt
if errorlevel 1 (
    echo    ✓ No issues message found - possibly clean!
) else (
    echo    Issues found - check analyze_result.txt for details
)

echo.
echo ===============================================
echo   Batch fix completed!
echo ===============================================
echo.
echo Summary of fixes applied:
echo - Fixed pubspec.yaml name field
echo - Fixed withOpacity deprecated usage
echo - Replaced print with debugPrint
echo - Updated dependencies
echo.
echo Run 'flutter analyze' to see remaining issues.
echo Run 'flutter run' to test the app.
echo.
pause
