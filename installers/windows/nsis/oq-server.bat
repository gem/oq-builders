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
set DJANGO_SETTINGS_MODULE=openquake.server.settings

if not exist python3\pycached (
   echo Building python cache. This may take a while.
   echo Please wait ...
   python.exe -m compileall -qq .
   copy /y nul python3\pycached >nul
)

if not exist python3\django_gem (
   echo Please wait while the system initializes.
   python3\Scripts\django-admin.exe openquake_engine_postinstall django_gem_taxonomy
   echo Runned django-admin  >> python3\django_gem
)

echo Starting OpenQuake Engine server
echo This may take some time, please wait...

REM Start the WebUI using django
oq webui start %OQ_HOST%:%OQ_PORT%

endlocal
exit /b 0






