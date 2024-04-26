@echo off
setlocal
set mypath=%~dp0
set PATH=%mypath%python3;%mypath%python3\Scripts;%mypath%GMT\bin;%PATH%
set NUMBA_CACHE_DIR=%TEMP%\openquake
set NUMEXPR_MAX_THREADS=8
set GMT_LIBRARY_PATH="%mypath%GMT\bin"
set GMT_SHARED="%mypath%GMT\share"
set OQ_HOST=localhost
set OQ_PORT=8800

if not exist python3\pycached (
   echo Building python cache. This may take a while.
   echo Please wait ...
   python.exe -m compileall -qq .
   copy /y nul python3\pycached >nul
)

echo Starting OpenQuake Engine server
echo This may take some time, please wait...

REM Start the WebUI using django
oq webui start %OQ_HOST%:%OQ_PORT%

endlocal
exit /b 0
