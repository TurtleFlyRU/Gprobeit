@>nul chcp 1251
@SetLocal EnableExtensions EnableDelayedExpansion
@Echo Off
rem Имя создаваемого файла с G-кодом измерения плоскости заготовки
set probefilename=probeitgcode.txt
rem Очистка текстового файла вывода
break >%probefilename%
echo (G code generated %DATE% %TIME%)>>%probefilename%
echo (BATCH script Gprobeit v.2020.01.10)>>%probefilename%
echo (turtlefly@yandex.ru)>>%probefilename%

rem Запрос о формате генерации
set /p format="G-code format: 1-w/o variables, 2-with variables: "
rem >> is add to file, but > is write file
rem echo (G-code format=%format%)>>%probefilename%
IF /I %format% == 2 (
set format=1
)

set /p xsize="Enter the size of the workpiece along the X axis (mm): "
rem echo Size workpiece along the X is - %xsize%
echo (X=%xsize%)>>%probefilename%

rem Запрос размера заготовки по оси Y
set /p ysize=" and the size along the Y axis (mm): "
rem echo Size workpiece along the Y is - %ysize%
echo (Y=%ysize%)>>%probefilename%

rem Офсет по осям X и Y , если по краю заготовки есть фаска
set /p xyoffset="Set offset XY axis (mm) if there is a chamfer: "
rem echo Offset size XY is - %xyoffset%
echo (XY offset=%xyoffset%)>>%probefilename%

rem Безопасная высота по оси Z
set /p zsafe="Set Z safe (mm): "
rem echo Zsafe - %zsafe%
echo (Z safe=%zsafe%)>>%probefilename%

rem Погружение на глубину по Z
set /p zdepth="Set depth of measurement along Z axis (mm): "
rem echo zdepth - %zdepth%
echo (Z zdepth=%zdepth%)>>%probefilename%

rem Шаг замера
set /p msize="Measurement step size (mm) X and Y direction: "
rem echo Measurement size - %msize%
echo (Measurement size=%msize%)>>%probefilename%

rem Вычисление количества точек замера по X
set /a xsection=((%xsize%-(%xyoffset%*2))/%msize%)+1
rem echo Xsection %xsection%
echo (Xsection %xsection%)>>%probefilename%

rem Вычисление количества точек замера по Y
set /a ysection=((%ysize%-(%xyoffset%*2))/%msize%)+1
rem echo Ysection %ysection%
echo (Ysection %ysection%)>>%probefilename%

rem Всего точек замера
set /A allsection=%xsection%*%ysection%
rem echo All section %allsection%
echo (All section %allsection%)>>%probefilename%

set /A XCounter=1
set /A YCounter=1
set /A Gpause=2000
set /A Fspeed=1000

IF /I %format% == 2 (
	rem переменная Безопасная Z
	echo #20=%zsafe%;>>%probefilename%
	rem переменная Безопасная Z
	echo #21=%zdepth%;>>%probefilename%
	rem пауза в миллисекундах для записи показаний с индикаторной головки
	echo #22=%Gpause%;>>%probefilename%
	rem скорость погружения инструмента по оси Z мм/мин или в процентах в NC
	echo #23=%Fspeed%;>>%probefilename%
)
echo G17;>>%probefilename% 
echo G21;>>%probefilename% 
echo G90;>>%probefilename%
echo M05;>>%probefilename%
echo (Start Surface Scan)>>%probefilename%
FOR /L %%y IN (0,1,%ysection%) DO (
	rem set /A YCounter=!YCounter!+1
	rem set /A yco=!YCounter!*%msize%
	rem echo YCounter=%YCounter% >>%probefilename%
rem Если крайние значения точек то надо ввести офсет по оси Y
		IF /I %%y == 0 (
			set /A yoffsetplus = %xyoffset%
			rem echo yoffsetplus=!yoffsetplus!
			) ELSE (
			set /A yoffsetplus = 0
			rem echo yoffsetplus=!yoffsetplus!
		)
		IF /I %%y == %ysection% (
			set /A yoffsetminus = %xyoffset%
			rem echo yoffsetminus=!yoffsetminus!
			) ELSE (
			set /A yoffsetminus = 0
			rem echo yoffsetminus=!yoffsetminus!
		)
	
	FOR /L %%x IN (0,1,%xsection%) DO (
rem Если крайние значения точек то надо ввести офсет по оси X
		IF /I %%x == 0 (
			set /A xoffsetplus = %xyoffset%
			rem echo xoffsetplus=!xoffsetplus!
			) ELSE (
			set /A xoffsetplus = 0
			rem echo xoffsetplus=!xoffsetplus!
		)
		IF /I %%x == %xsection% (
			set /A xoffsetminus = %xyoffset%
			rem echo xoffsetminus=!xoffsetminus!
			) ELSE (
			set /A xoffsetminus = 0
			rem echo xoffsetminus=!xoffsetminus!
		)
		set /A xpoint = "!xoffsetplus!+(%%x*1*%msize%)-!xoffsetminus!"
		set /A ypoint = "!yoffsetplus!+(%%y*1*%msize%)-!yoffsetminus!"
		
			IF /I %format% == 1 (
				rem Генерация G-кода без использования переменных 
				echo G0 Z%zsafe%;>>%probefilename%
				echo G0 X!xpoint!Y!ypoint!;>>%probefilename% 
				rem вызов подпрограммы P - с названием 1001, L - количество повторов
				echo G65 P"TEST-Z";>>%probefilename%
				rem echo G01 Z-%zdepth% F%Fspeed%;>>%probefilename%
				rem Вывод координат в панель сообщений NcStudio, оттуда они автоматически попадают в лог NcStudio.log
				rem Для упрощения обработки лога NcStudio.log перед координатой X добавлена запятая
				rem echo M801 MSG",{#CURWORKPOS.X},{#CURWORKPOS.Y},{#CURWORKPOS.Z}";>>%probefilename%
				echo G04 P%Gpause%;>>%probefilename%
			) ELSE (
				rem Генерация G-кода с переменными (не везде работают)
				rem Пока отложим такой вариант 
				rem echo G0 X!xpoint!Y!ypoint!;>>%probefilename% 
				rem echo G01 Z[0-#21] F#23;>>%probefilename%
				rem echo G04 P#22;>>%probefilename%
				rem echo G0 Z#20;>>%probefilename%
			)
		)
	)
rem (Метка окончания блока измерений. Ориентир для работы парсера. Не менять!)
echo (End Surface Scan)>>%probefilename%
rem Конец программы, без сброса модальных функций.
echo M02;>>%probefilename%
rem Конец управляющей программы, со сбросом модальных функций.
rem echo M30;>>%probefilename%


rem =====================================================================
rem Процедура измерения высоты заготовки
echo '##### Workpiece height measurement procedure #####>>%probefilename%
echo O"TEST-Z";>>%probefilename%
rem Ругается на скобку в IF, хз почему
rem echo IF(#CUTLINE_PORT != -1) M901 H=#CUTLINE_PORT P0;>>%probefilename%
rem M802 Pxxxx Эта команда используется для передачи целочисленного сообщения.		
rem M802 P196609 'close the buffer zone
echo M802 P196609 >>%probefilename%
rem Сообщение об ожидании сигнала касания заготовки
echo M801 MSG"|D|Waiting for a workpiece touch signal";>>%probefilename%
rem Описание команды
rem G904 FX_PX_LX_FY_PY_LY_FZ_PZ_LZ_X_Y_Z_
rem Ненужные оси могут быть опущены. Однако после появления оси, за исключением X_Y_Z_, остальные данные должны быть полными.
rem FX_, FY_, FZ_: скорость движения и направление осей X, Y и Z
rem PX_, PY_, PZ_: номер порта сигнала для обнаружения осей X, Y и Z
rem LX_, LY_, LZ_: состояние сигнала, которое ожидается для остановки движения осей X, Y и Z (1: включено; 0: выключено)
rem X_, Y_, Z_: самое длинное расстояние перемещения
rem Двигаем ось Z вниз до момента касания датчика и останавливаем движение(или до касания поверхности заготовки, если заготовка металлическая и соприкасается с датчиком), т.е. до появления логической единицы на входе датчика 
echo G904 FZ=-#CALIBRATION_SPEED*60 PZ=#CALIBRATION_SW LZ1;>>%probefilename%
rem Двигаем ось Z вверх до момента пропадания сигнала от датчика и останавливаем ось
echo G904 FZ=#CALIBRATION_SPEED*6 PZ=#CALIBRATION_SW LZ0;>>%probefilename%
rem а вот в этом месте, пожалуй, надобы сделать вывод всех координат, и эта строка пойдёт в разбор полётов
rem !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo M801 MSG",{#CURWORKPOS.X},{#CURWORKPOS.Y},{#CURWORKPOS.Z}";>>%probefilename%
rem Двигаем ось Z вверх на 0.1 относительно момента пропадания контакта между осью Z и датчиком
rem Вообще, тоже надо-бы убрать, т.к. более точную процедуру не буду запускать, или уменьшить этот отскок
rem !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo G91 G01 Z0.1;>>%probefilename%
rem Пауза для успокоения колебаний, мс
echo G04 P1000;>>%probefilename%
rem Эти переменные #43 и #50 обнуляются в этой подпрограмме
rem и далее они вычисляются в следующей подпрограмме более точного и медленого касания.
rem Так было в файле public.dat НО тут они не нужны.
rem echo #43=0;#50=0;>>%probefilename%
rem Процедура более точного определения координаты касания, т.е. более медленного, с меньшим шаго и с меньшей скоростью, т.к. уже известно что мы зависли примерно в 0,1 от поверхности
rem И её пропустим..
rem echo 	G65 P"CALI-Z-ONCE" L=#CALIBRATION_TIMES #41=-20 #42=#CALIBRATION_SW
rem echo G91 G01 Z0.2;>>%probefilename%
rem echo G04 P200;>>%probefilename%
rem Синхронизация параметров
echo G906;>>%probefilename%
rem echo 	if(#43)M801 MSG"|E|Calibration error is out of limit!" M30
rem echo 	if(!#43)M801 MSG"|M|Calibration is over! Measurements is: {#50}"
rem Установка нулей заготовки в текущем WCS
rem G921 X_Y_Z_
rem X_Y_Z_: установить координаты заготовки текущей точки в текущем WCS
rem Не включенные в список оси не будут изменены; настройка действительна только для текущего WCS.
rem Тоже не понадобилась, выключаем..
rem echo G921 Z=#MOBICALI_THICKNESS+5-#PUB_OFFSET.Z
echo G90;>>%probefilename%
echo M17;>>%probefilename%
rem =====================================================================
echo '#################################################>>%probefilename%
pause

