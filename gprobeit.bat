@>nul chcp 1251
@SetLocal EnableExtensions EnableDelayedExpansion
@Echo Off

set cautiontxt=Be careful! Check and simulate the resulting G-code before running.
set scriptname=Gprobeit
set scriptver=v.2020.01.17
rem ��� ������������ ����� � G-����� ��������� ��������� ���������
set probefilename=probeitgcode.txt
rem ������� ���������� ����� ������
break >%probefilename%
echo %cautiontxt%
echo (%cautiontxt%)>>%probefilename%
echo (G code generated %DATE% %TIME%)>>%probefilename%
echo BATCH script %scriptname% %scriptver%
echo (BATCH script %scriptname% %scriptver%)>>%probefilename%

rem ������ ������ ����� ������
rem ===================================================================
rem ������ � ������� ���������. �� ���� �� ������ ����, ��� ������� �������� � NcStudio 8. 
set /p format="G-code format: 1 - w/o variables for NcStudio, 2 - exit: "
rem >> is add to file, but > is write file
rem echo (G-code format=%format%)>>%probefilename%
IF /I %format% NEQ 1 (
exit /b
)

set /p xsize="Enter the size of the workpiece along the X axis (mm): "
rem echo Size workpiece along the X is - %xsize%
echo (X=%xsize%)>>%probefilename%

rem ������ ������� ��������� �� ��� Y
set /p ysize=" and the size along the Y axis (mm): "
rem echo Size workpiece along the Y is - %ysize%
echo (Y=%ysize%)>>%probefilename%

rem ����� �� ���� X � Y , ���� �� ���� ��������� ���� ����� ��� �������������� �����
set /p xyoffset="Set offset XY axis (mm) if there is a chamfer: "
rem echo Offset size XY is - %xyoffset%
echo (XY offset=%xyoffset%)>>%probefilename%

rem ���������� ������ �� ��� Z
set /p zsafe="Set Z safe (mm): "
rem echo Zsafe - %zsafe%
echo (Z safe=%zsafe%)>>%probefilename%

rem ��� �� ������������
rem ���������� �� ������� �� Z
rem set /p zdepth="Set depth of measurement along Z axis (mm): "
rem echo zdepth - %zdepth%
rem echo (Z zdepth=%zdepth%)>>%probefilename%

rem ��� ������
set /p msize="Measurement step size (mm) X and Y direction: "
rem echo Measurement size - %msize%
echo (Measurement size=%msize%)>>%probefilename%
rem ������ �������
rem ===================================================================

rem ���������� ���������� ����� ������ �� X
set /a xsection=((%xsize%-(%xyoffset%*2))/%msize%)
rem echo Xsection %xsection%
echo (Xsection %xsection%)>>%probefilename%

rem ���������� ���������� ����� ������ �� Y
set /a ysection=((%ysize%-(%xyoffset%*2))/%msize%)
rem echo Ysection %ysection%
echo (Ysection %ysection%)>>%probefilename%

rem ����� ����� ������
set /A allsection=%xsection%*%ysection%
rem echo All section %allsection%
echo (All section %allsection%)>>%probefilename%

set /A XCounter=1
set /A YCounter=1
set /A Gpause=500
rem set /A Fspeed=1000
set /A Xlastpoint=%xsize%-%xyoffset%
set /A Ylastpoint=%ysize%-%xyoffset%

rem ���������� ��� � �������� ������ G ���
rem ===================================================================
echo G17;>>%probefilename% 
echo G21;>>%probefilename% 
echo G90;>>%probefilename%
rem ��������� ��������, �.�. � NcStudio, �� ���������, �� ������������� ���������� ��� ������� ����� ���������.
rem � �������� ��������� ��������� ��� ������ ������������ ����������� ��� �� �������.
echo M05;>>%probefilename%
rem �������� � ����� ������ ���������
echo G0 Z%zsafe%;>>%probefilename%
echo G0 X0Y0;>>%probefilename% 
rem ��������� � ������������ �����������
echo (Start Surface Scan)>>%probefilename%
FOR /L %%y IN (%xyoffset%,%msize%,%Ylastpoint%) DO (
	FOR /L %%x IN (%xyoffset%,%msize%,%Xlastpoint%) DO (
		set /A xpoint = %%x
		set /A ypoint = %%y
			IF /I %format% == 1 (
				rem ��������� G-���� ��� ������������� ���������� 
				echo G0 Z%zsafe%;>>%probefilename%
				echo G0 X!xpoint!Y!ypoint!;>>%probefilename% 
				rem ����� ������������
				echo G65 P"TEST-Z";>>%probefilename%
				echo G04 P%Gpause%;>>%probefilename%
			) ELSE (
				rem ���� ����� ���� �� ��������
				rem ��������� G-���� � ����������� (�� ����� ��������)
				rem ���� ������� ����� ������� 
				rem echo G0 X!xpoint!Y!ypoint!;>>%probefilename% 
				rem echo G01 Z[0-#21] F#23;>>%probefilename%
				rem echo G04 P#22;>>%probefilename%
				rem echo G0 Z#20;>>%probefilename%
			)
		)
	)
rem (����� ��������� ����� ���������. �������� ��� ������ �������. �� ������!)
echo (End Surface Scan)>>%probefilename%
echo G0 Z%zsafe%;>>%probefilename%
rem ����� ���������, ��� ������ ��������� �������.
echo M02;>>%probefilename%
rem ����� ����������� ���������, �� ������� ��������� �������.
rem echo M30;>>%probefilename%


rem =====================================================================
rem ��������� ��������� ������ ���������
echo '##### Workpiece height measurement procedure #####>>%probefilename%
echo O"TEST-Z";>>%probefilename%
rem �������� �� ������ � IF, �� ������
rem echo IF(#CUTLINE_PORT != -1) M901 H=#CUTLINE_PORT P0;>>%probefilename%
rem M802 Pxxxx ��� ������� ������������ ��� �������� �������������� ���������.		
rem M802 P196609 'close the buffer zone
echo M802 P196609 >>%probefilename%
rem ��������� �� �������� ������� ������� ���������
echo M801 MSG"|D|Waiting for a workpiece touch signal";>>%probefilename%
rem �������� �������
rem G904 FX_PX_LX_FY_PY_LY_FZ_PZ_LZ_X_Y_Z_
rem �������� ��� ����� ���� �������. ������ ����� ��������� ���, �� ����������� X_Y_Z_, ��������� ������ ������ ���� �������.
rem FX_, FY_, FZ_: �������� �������� � ����������� ���� X, Y � Z
rem PX_, PY_, PZ_: ����� ����� ������� ��� ����������� ���� X, Y � Z
rem LX_, LY_, LZ_: ��������� �������, ������� ��������� ��� ��������� �������� ���� X, Y � Z (1: ��������; 0: ���������)
rem X_, Y_, Z_: ����� ������� ���������� �����������
rem ������� ��� Z ���� �� ������� ������� ������� � ������������� ��������(��� �� ������� ����������� ���������, ���� ��������� ������������� � ������������� � ��������), �.�. �� ��������� ���������� ������� �� ����� ������� 
echo G904 FZ=-#CALIBRATION_SPEED*60 PZ=#CALIBRATION_SW LZ1;>>%probefilename%
rem ������� ��� Z ����� �� ������� ���������� ������� �� ������� � ������������� ���
echo G904 FZ=#CALIBRATION_SPEED*6 PZ=#CALIBRATION_SW LZ0;>>%probefilename%
rem � ��� � ���� �����, �������, ������ ������� ����� ���� ���������, � ��� ������ ����� � ������ ������
rem !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
rem ����� ��������� � ������ ��������� NcStudio, ������ ��� ������������� �������� � ��� NcStudio.log
rem ��� ��������� ��������� ���� NcStudio.log ����� ����������� X ��������� �������
echo M801 MSG",{#CURWORKPOS.X},{#CURWORKPOS.Y},{#CURWORKPOS.Z}";>>%probefilename%
rem ������� ��� Z ����� �� 0.1 ������������ ������� ���������� �������� ����� ���� Z � ��������
rem ������, ���� ����-�� ������, �.�. ����� ������ ��������� �� ���� ���������, ��� ��������� ���� ������
rem !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo G91 G01 Z0.1;>>%probefilename%
rem ����� ��� ���������� ���������, ��
echo G04 P200;>>%probefilename%
rem ��� ���������� #43 � #50 ���������� � ���� ������������
rem � ����� ��� ����������� � ��������� ������������ ����� ������� � ��������� �������.
rem ��� ���� � ����� public.dat �� ��� ��� �� �����.
rem echo #43=0;#50=0;>>%probefilename%
rem ��������� ����� ������� ����������� ���������� �������, �.�. ����� ����������, � ������� ���� � � ������� ���������, �.�. ��� �������� ��� �� ������� �������� � 0,1 �� �����������
rem � � ���������..
rem echo 	G65 P"CALI-Z-ONCE" L=#CALIBRATION_TIMES #41=-20 #42=#CALIBRATION_SW
rem echo G91 G01 Z0.2;>>%probefilename%
rem echo G04 P200;>>%probefilename%
rem ������������� ����������
echo G906;>>%probefilename%
rem echo 	if(#43)M801 MSG"|E|Calibration error is out of limit!" M30
rem echo 	if(!#43)M801 MSG"|M|Calibration is over! Measurements is: {#50}"
rem ��������� ����� ��������� � ������� WCS
rem G921 X_Y_Z_
rem X_Y_Z_: ���������� ���������� ��������� ������� ����� � ������� WCS
rem �� ���������� � ������ ��� �� ����� ��������; ��������� ������������� ������ ��� �������� WCS.
rem ���� �� ������������, ���������..
rem echo G921 Z=#MOBICALI_THICKNESS+5-#PUB_OFFSET.Z
echo G90;>>%probefilename%
echo M17;>>%probefilename%
rem =====================================================================
echo '#################################################>>%probefilename%
echo %cautiontxt%
echo (%cautiontxt%)>>%probefilename%
pause