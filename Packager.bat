@echo off
setlocal enabledelayedexpansion

rem =========================================================
rem  package_mods.bat
rem
rem  Zips each mod folder in gamedata\turd\ into its own
rem  zip file, keeping the gamedata\turd\<modname>\... path
rem  structure INSIDE the zip (so extracting it at the game
rem  root recreates gamedata\turd\<modname>\...).
rem
rem  Requires tar.exe, which ships with Windows 10/11 by
rem  default. If "tar is not recognized" shows up, see the
rem  note at the bottom of this file.
rem =========================================================

set "root=%~dp0"
set "moddir=%root%gamedata\turd"
set "outdir=%root%packaged_mods"

rem tar chokes if a quoted path ends in a backslash right before the
rem closing quote (Windows argument parsing treats \" as an escaped
rem quote). Strip the trailing backslash from root before using it
rem as the -C argument to tar.
set "rootnoslash=%root%"
if "%rootnoslash:~-1%"=="\" set "rootnoslash=%rootnoslash:~0,-1%"

if not exist "%moddir%" (
    echo Could not find "%moddir%"
    echo Make sure this batch file sits next to the gamedata folder.
    pause
    exit /b 1
)

if not exist "%outdir%" mkdir "%outdir%"

echo Packaging mods from "%moddir%"
echo Output zips will go to "%outdir%"
echo.

for /d %%D in ("%moddir%\*") do (
    set "modname=%%~nxD"
    echo Zipping "!modname!" ...
    tar -a -c -f "%outdir%\!modname!.zip" -C "%rootnoslash%" "gamedata\turd\!modname!"
    if errorlevel 1 (
        echo   FAILED to zip !modname!
    ) else (
        echo   Done: !modname!.zip
    )
)

echo.
echo All mods processed. Zips are in "%outdir%".
pause

rem ---------------------------------------------------------
rem If tar isn't available on this machine (rare on Win10/11):
rem   1. Open PowerShell in this folder instead
rem   2. Run a loop like:
rem      Get-ChildItem "gamedata\turd" -Directory | ForEach-Object {
rem          $name = $_.Name
rem          Compress-Archive -Path "gamedata\turd\$name" -DestinationPath "packaged_mods\$name.zip" -Force
rem      }
rem      NOTE: this PowerShell version nests the zip differently
rem      (top-level folder becomes gamedata\turd\<mod> is NOT
rem      preserved the same way) - tar is the reliable option.
rem ---------------------------------------------------------