@echo off
setlocal
set mypath=%~dp0
set PATH=%mypath%python3;%mypath%python3\Scripts;%mypath%GMT\bin;%PATH%
set NUMBA_CACHE_DIR=%TEMP%\openquake
set NUMEXPR_MAX_THREADS=8
set GMT_LIBRARY_PATH="%mypath%GMT\bin"
set GMT_SHARED="%mypath%GMT\share"
set DJANGO_SETTINGS_MODULE=openquake.server.settings
echo Run django-admin 
python3\Scripts\django-admin.exe openquake_engine_postinstall django_gem_taxonomy
endlocal
