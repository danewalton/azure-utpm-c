@REM Copyright (c) Microsoft. All rights reserved.
@REM Licensed under the MIT license. See LICENSE file in the project root for full license information.

@setlocal EnableExtensions EnableDelayedExpansion
@echo OFF

set current-path=%~dp0
rem // remove trailing slash
set current-path=%current-path:~0,-1%

echo Current Path: %current-path%

set build-root=%current-path%\..
rem // resolve to fully qualified path
for %%i in ("%build-root%") do set build-root=%%~fi

set repo_root=%build-root%
rem // resolve to fully qualified path
for %%i in ("%repo_root%") do set repo_root=%%~fi

set CMAKE_DIR=tpm_win32
set build-config=Debug
set build-platform=Win32

echo Build Root: %build-root%
echo Repo Root: %repo_root%

echo CMAKE Output Path: %build-root%\cmake\%CMAKE_DIR%

if EXIST %build-root%\cmake\%CMAKE_DIR% (
    rmdir /s/q %build-root%\cmake\%CMAKE_DIR%
    rem no error checking
)

echo %build-root%\cmake\%CMAKE_DIR%
mkdir %build-root%\cmake\%CMAKE_DIR%
rem no error checking
pushd %build-root%\cmake\%CMAKE_DIR%

echo ***checking msbuild***
where /q msbuild
IF ERRORLEVEL 1 (
echo ***setting VC paths***
    IF EXIST "%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Enterprise\Common7\Tools\VsMSBuildCmd.bat" call "%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Enterprise\Common7\Tools\VsMSBuildCmd.bat"
)
where msbuild

cmake %build-root% -Drun_unittests:BOOL=ON 
if not !ERRORLEVEL!==0 exit /b !ERRORLEVEL!

msbuild /m utpm.sln "/p:Configuration=%build-config%;Platform=%build-platform%"
if not !ERRORLEVEL!==0 exit /b !ERRORLEVEL!

if %build-platform% neq arm (
    ctest -C "debug" -V
    if not !ERRORLEVEL!==0 exit /b !ERRORLEVEL!
)

popd