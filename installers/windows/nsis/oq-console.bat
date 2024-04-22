@echo off
setlocal
set mypath=%~dp0
set PATH=%mypath%\python3;%mypath%\python3\Scripts;%mypath%\GMT\bin;%PATH%
set NUMBA_CACHE_DIR=%TEMP%\openquake
set NUMEXPR_MAX_THREADS=8
set GMT_LIBRARY_PATH="%mypath%\GMT\bin"
set GMT_SHARED="%mypath%\GMT\share"

if not exist python3\pycached (
   echo Building python cache. This may take a while.
   echo Please wait ...
   python.exe -m compileall -qq .
   copy /y nul python3\pycached >nul
)

echo OpenQuake environment loaded
echo To run OpenQuake use 'oq' and 'oq engine'
cmd /k

endlocal
