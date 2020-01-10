@>nul chcp 1251
@SetLocal EnableExtensions EnableDelayedExpansion
@Echo Off
Echo Start
@break>001_result_surf_scan.txt
set srclogfile=NcStudio.log
set tmplogfile=NcStudio.log.tmp
set strnumstart=
set strnumend=

rem more NcStudio.log | find /c /v ""
rem findstr /n /c:"Start Surface Scan" NcStudio.log
rem findstr /n /c:"End Surface Scan" NcStudio.log 
Echo Create temp file.
copy  %srclogfile% %tmplogfile%
Echo Search marks.
find /n /i "Start Surface Scan" %tmplogfile%
find /n /i "End Surface Scan" %tmplogfile%

rem for /f "tokens=2-4 delims=," %%A in (NcStudio.log) do (
rem	 echo X%%A Y%%B Z%%C
rem	)

for /f "skip=2 delims=[]" %%i in ('find /n /i "Start Surface Scan" %tmplogfile%') do (
  set strnumstart=%%i
  )
for /f "skip=2 delims=[]" %%i in ('find /n /i "End Surface Scan" %tmplogfile%') do (
  set strnumend=%%i
  )
rem skip leading space
echo Last START string number=%strnumstart%
echo Last END string number=%strnumend%

rem for /f "skip=%strnumstart:~1% tokens=2-4 delims=," %%A in (NcStudio.log) do (
rem 	echo X%%A Y%%B Z%%C
rem	)
Echo Save result to 001_result_surf_scan.txt
for /f "skip=%strnumstart% tokens=2-4 delims=," %%A in (%tmplogfile%) do (
	echo %%A,%%B,%%C>>001_result_surf_scan.txt
	)
Echo Delete temp file
del /F /Q %tmplogfile%
Echo End
pause