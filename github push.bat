@echo off
setlocal

:: Verify we are inside a Git repository
git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
    echo [ERROR] This folder is not a Git repository.
    pause
    exit /b 1
)

:: Check if there are any modified, added, or deleted files
git status --porcelain > "%TEMP%\git_changes.txt"
for %%A in ("%TEMP%\git_changes.txt") do set SIZE=%%~zA

if "%SIZE%"=="0" (
    echo No local changes to commit.
    del "%TEMP%\git_changes.txt" >nul 2>&1
    pause
    exit /b 0
)

echo ==================================================
echo Files to be committed:
echo ==================================================
git status --short
echo ==================================================
echo.

set /p MSG="Enter commit message (or press Enter for default): "
if "%MSG%"=="" set MSG=Update lecture notes

echo.
echo Staging all changes...
git add -A
if errorlevel 1 (
    echo [ERROR] git add failed.
    del "%TEMP%\git_changes.txt" >nul 2>&1
    pause
    exit /b 1
)

echo Committing changes...
git commit -m "%MSG%"
if errorlevel 1 (
    echo [ERROR] git commit failed.
    del "%TEMP%\git_changes.txt" >nul 2>&1
    pause
    exit /b 1
)

echo.
echo ==================================================
echo Files included in this commit:
echo ==================================================
git show --stat --oneline HEAD
echo ==================================================
echo.

echo Pushing to origin main...
git push origin main
if errorlevel 1 (
    echo [ERROR] git push failed.
    del "%TEMP%\git_changes.txt" >nul 2>&1
    pause
    exit /b 1
)

echo.
echo Push completed successfully.
del "%TEMP%\git_changes.txt" >nul 2>&1
pause