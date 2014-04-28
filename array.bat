@ECHO off
rem Включаем отложеную подстановку переменных (ENABLEDELAYEDEXPANSION)
rem Нужно для того, чтобы переменные виже !var! подставлялись в момент выполнения
rem В противном случае внутри блоков if переменные нельзя будет менять
rem Включием расширенную обработку комманд (ENABLEEXTENSIONS)
rem В частности для того, чтобы можно было использовать параметр /I в if.
setlocal ENABLEDELAYEDEXPANSION ENABLEEXTENSIONS

rem =====  Arrays =====
rem Важно помнить, что после каждого вызова функции удаляются все переменные, начинающиеся на __
:array
	rem Сохранение аргументов в локальных переменных
	rem чтобы можно было обращать отложенным методом !__1!
	rem ~ - убрать кавычки
	set __1=%~1
	set __2=%~2
	set __3=%~3
	set __4=%~4
	set __5=%~5
	set __6=%~6

	
	rem == create ==
	rem Создание массива
	rem call :array create имя_массива [размер=0] [начальные значения=0]
	if /I "!__1!"=="create" (

		rem Имя массива
		if "!__2!"=="" (
			echo Не указано имя массива
			goto :eof
		)
		set _name=array_!__2!
		
		rem Размер
		set /a _count=0
		if not "!__3!"=="" (
			set /a _count = !__3!
		)
		
		rem Начальные значения
		set _defval=0
		if not "!__4!"=="" (
			set _defval=!__4!
		)
		
		rem Удаление массива, если существует c таким же именем
		rem Можно было не удалять все переменные, а только оставшиеся после перезаписи, но может быть как-нибудь потом
		call :array_del_ifdef !__2!
		
		set /a __maxindex=!_count!-1
		
		for /l %%i in (0,1,!__maxindex!) do set !_name!_%%i=!_defval!
		set /a !_name!_count = !_count!
		
		set _name=
		set _count=
		set _defval=
		
	rem == new ==
	rem Создание массива из набора значений
	rem call :array new имя_массива "знач1, знач2, 'строка' ..."
	) else if /I "!__1!"=="new" (
	
		rem Имя массива
		if "!__2!"=="" (
			echo Не указано имя массива
			goto :eof
		)
		
		if "!__3!"=="" (
			echo Не указан набор значений
			goto :eof
		)
		


		rem Заменяем одинарные кавычки на двойные
		set _elems=!__3:'="!
		
		set _name=array_!__2!
		
		rem Удаление массива, если существует c таким же именем
		call :array_del_ifdef !__2!
		
		rem Создаем последовательно каждый элемент и присваиваем значение
		set /a __i=0
		for %%i in (!_elems!) do (
			rem ~ - убираем кавычки, которые необходимя просто для группировки
			set !_name!_!__i!=%%~i
			set /a __i+=1
		)
		
		set /a !_name!_count=!__i!
		set _elems=
		
	rem == get ==
	rem Получение элемента массива (сохранение в переменную)
	rem call :array get имя_массива [index=0] [имя_целевой_переменной=_l]
	rem Если индекс отрицательный, то он считается с конца (-1 - последний, -2 - предпоследний и т.д.)
	) else if /I "!__1!"=="get" (

		rem Имя массива
		if "!__2!"=="" (
			echo Не указано имя массива
			goto :eof
		)
		set __name=array_!__2!
		
		rem Проверка существования массива
		call :array_notdefined !__2! __errors
		
		rem Если есть ошибки, то выходим
		if not !__errors!==0 goto :eof
		
		rem Индекс элемента
		set /a __i = 0
		if not "!__3!"=="" (
			set /a __i = !__3!
		)

		rem Если индекс отрицательный, то считаем с конца
		if !__i! LSS 0 (
			rem Получаем размер
			call :set __count !__name!_count
			set /a __i=!__count!+!__i!
		)
		

		rem Имя переменной, содержащей значение элемента
		set __target=!__name!_!__i!
		
		rem Проверка существования элемента
		if not defined !__target! (
			echo В массиве !__2! нет элемента с индексом !__i!
			goto :eof
		)
		
		rem Записываем значение элемента во временную переменную
		call :set __value !__target!
		set __var=_l
		if not "!__4!"=="" (
			set __var=!__4!
		)
		
		rem Записываем в целевую
		call :set !__var! __value
	
	
	
	rem == echo ==
	rem Вывод значения элемента на экран
	) else if /I "!__1!"=="echo" (
		
		call :array get !__2! !__3! _tmpval
		if not "!_tmpval!"=="" (
			echo !_tmpval!
		)
		set _tmpval=
		

	rem == list ==
	rem Вывод значений списком. Может быть полезно при перенаправлении вывода
	rem call :array list имя_массива
	rem Пример: call :array list myArr > array.txt  - сохраняет текущий массив в файт array.txt
	rem Для сохранения в кодировке cp1251 используйте save
	) else if /I "!__1!"=="list" (
		
		rem Имя массива
		if "!__2!"=="" (
			echo Не указано имя массива
			goto :eof
		)
		
		
		rem Проверка существования массива
		call :array_notdefined !__2! __errors
		
		rem Если есть ошибки, то выходим
		if not !__errors!==0 goto :eof
		
		set __name=array_!__2!
		
		rem Получаем размер
		call :set __count !__name!_count
		set /a __maxindex=!__count!-1
		
		rem Вывод значений
		for /l %%i in (0,1,!__maxindex!) do (
			call :set __value !__name!_%%i
			echo !__value!
		)
	
	rem == save ==
	rem Сохраняет массив в указанный файл в кодировке cp1251
	rem call :array save имя_массива имя_файла
	) else if /i "!__1!"=="save" (
	
		rem Имя файла
		if "!__3!"=="" (
			echo Не указано имя файла
			goto :eof
		)
		
		rem Парсим вывод команды chcp, ищим номер кодовой страницы и запаминаем
		for /f "usebackq tokens=2 delims=:" %%i in (`chcp`) do set /a _pageset=%%i
		
		rem Меняем кодовую страницу на 1251
		chcp 1251>nul
		rem Перенаправляем вывод list в файл
		call :array list !__2! > !__3!
		rem Возвращаем кодовую страницу
		chcp !_pageset!>nul
		
		
		set _pageset=
		
		
	rem == load ==
	rem Чтение в массив из файла, с кодировкой cp1251
	rem call :array load имя_массива имя_файла
	) else if /i "!__1!"=="load" (
		rem Имя массива
		if "!__2!"=="" (
			echo Не указано имя массива
			goto :eof
		)
		
		rem Имя файла
		if "!__3!"=="" (
			echo Не указано имя файла
			goto :eof
		)
		
		if not exist "!__3!" (
			echo Файл !__3! не найден
			goto :eof
		)
		
		set _file=!__3!
		set _shortname=!__2!
		
		
		rem Удаляем массив, если сущестует
		call :array_del_ifdef !__2!

		rem Парсим вывод команды chcp, ищим номер кодовой страницы и запаминаем
		for /f "usebackq tokens=2 delims=:" %%i in (`chcp`) do set /a _pageset=%%i
		
		rem Меняем кодовую страницу на 1251
		chcp 1251>nul
		
		rem Вносим каждую строку файла в массив
		rem Используем call, чтобы выполнялось в новой кодовой странице
		call :array load_unsafe !_shortname! !_file!
				
		rem Возвращаем кодовую страницу
		chcp !_pageset!>nul

		set _name=
		set _file=
		set _pageset=
		set _shortname=
		
	rem == load_unsafe ==
	rem Чтение массива из файла небезопасное. 
	rem Нет проверок, нет удаления существующего массива, что ведёт к засорению памяти
	rem Используется при load
	) else if /I "!__1!"=="load_unsafe" (
		
		set __i=0
		rem Вносим каждую строку файла в массив
		for /f "tokens=*" %%i in (!__3!) do (
			set array_!__2!_!__i!=%%i
			set /a __i+=1
		)
		set array_!__2!_count=!__i!
		

	rem == count ==
	rem Количество элементов в массиве
	rem call :array count имя_массива [имя_целевой_переменной=_l]
	) else if /I "!__1!"=="count" (
	
	
		rem Имя массива
		if "!__2!"=="" (
			echo Не указано имя массива
			goto :eof
		)
		
		
		rem Проверка существования массива
		call :array_notdefined !__2! __errors
		
		rem Если есть ошибки, то выходим
		if not !__errors!==0 goto :eof
		
		set __name=array_!__2!
		
		rem Имя целевой переменной
		set __var=_l
		if not "!__3!"=="" (
			set __var=!__3!
		)
		
		rem Записываем в целевую
		call :set !__var! !__name!_count
		
	rem == dump ==
	rem Вывод массива на экран
	rem call :array dump имя_массива
	) else if /I "!__1!"=="dump" (
	
		rem Имя массива
		if "!__2!"=="" (
			echo Не указано имя массива
			goto :eof
		)
		
		
		rem Проверка существования массива
		call :array_notdefined !__2! __errors
		
		rem Если есть ошибки, то выходим
		if not !__errors!==0 goto :eof
		
		set __name=array_!__2!
		
		rem Получаем размер
		call :set __count !__name!_count
		set /a __maxindex=!__count!-1
		
		echo array[!__count!]: !__2!
		if !__count!==0 (
			echo Массив не содержит элементов
			goto :eof
		)
		
		for /l %%i in (0,1,!__maxindex!) do (
			call :set __value !__name!_%%i
			echo [%%i] !__value!
		)

		
	
	rem == set ==
	rem Присвоение значения элементу
	rem call :array set имя_массива индекс значение
	) else if /I "!__1!"=="set" (
		
		if "!__4!"=="" (
			echo Не указано значение. Значение не может быть пустым
			goto :eof
		)
		rem Сохраняем параметры, для того, чтобы после вызова get они не потерялись	
		set _name=array_!__2!
		set /a _i=!__3!
		set _value=!__4!
			
		rem Получение значения обеспечивает нам проверку параметров
		rem Важно. После операции все локальные переменные (__*) очищаются
		call :array get !__2! !__3! _localresult
		

		rem Если результат get существует, то удаляем элемент
		rem Сообщения об ошибках в противном случае покажет сам get
		if defined _localresult (
			set !_name!_!_i!=!_value!
		)
		
		set _localresult=
		set _name=
		set _i=
		set _value=
		
	
	rem == delete ==
	rem Удаление массива
	rem call :array delete имя_массива
	) else if /I "!__1!"=="delete" (
	
		rem Имя массива
		if "!__2!"=="" (
			echo Не указано имя массива
			goto :eof
		)
		
		
		rem Проверка существования массива
		call :array_notdefined !__2! __errors
		
		rem Если есть ошибки, то выходим
		if not !__errors!==0 goto :eof
		
		set __name=array_!__2!
		
		rem Получаем размер
		call :set __count !__name!_count
		set /a __maxindex=__count-1
		
		rem Удаляем все элементы
		for /l %%i in (0,1,!__maxindex!) do set !__name!_%%i=
		rem Удаляем размер
		set !__name!_count=
				
	rem == del ==
	rem Удаление элемента, элементов или всего массива
	rem call :array del имя_массива [индекс_элемента|набор элементов=удаление всего массива]
	rem Примеры:	call :array del myArr "4,6,8"  -  удаляет из массива myArr элементы с индексами 4, 6 и 8
	rem 			call :array del myArr 9  -  удаляет из массива myArr 9й элемент
	rem				call :array del myArr	-	удаляет массив myArr
	) else if /I "!__1!"=="del" (
	
		rem Если не указан индекс, то удаляем весь массив		
		if "!__3!"=="" (
			call :array delete !__2!
			goto :eof
		)
		
		rem Если параметр не число, то перенаправляем на удаление по списку индексов
		set __localresult=
		call :is_number "!__3!" __localresult
		if !__localresult!==0 (
			call :array del_elements !__2! "!__3!"
			goto :eof
		)
		
		
		rem Если индекс указан, то удаляем только элемент
		
		rem Сохраняем параметры, для того, чтобы после вызова get они не потерялись	
		set _name=array_!__2!
		set /a _i=!__3!
			
		rem Получение значения обеспечивает нам проверку параметров
		rem Важно. После операции все локальные переменные (__*) очищаются
		set _localresult=
		call :array get !__2! !__3! _localresult
		rem Если результат get не существует, то выходим
		rem Сообщения об ошибках в этом случае покажет сам get
		if not defined _localresult (
			set _name=
			goto :eof
		)
		set _localresult=

		
		rem Получаем размер
		call :set __count !_name!_count
		rem maxindex=count-2, так как идём до предпоследнего элемента
		set /a __maxindex=__count-2
		set /a __nextindex=!_i!

		rem Пересчёт индексов
		for /l %%i in (!_i!,1,!__maxindex!) do (
			set /a __nextindex+=1
			call :set !_name!_%%i !_name!_!__nextindex!
		)
		
		set /a !_name!_count-=1
		
		rem Удаление последнего элемента (он был перемещёт на позицию вверх)
		set !_name!_!__nextindex!=
		
		rem Удаляем локальные переменные
		set _name=
		set _i=
	

	rem == del_elements ==
	rem Удаление элементов по списку индексов
	rem call :array del_elements имя_массива
	rem Лучше использовать del
	) else if /I "!__1!"=="del_elements" (
	
		rem Имя массива
		if "!__2!"=="" (
			echo Не указано имя массива
			goto :eof
		)
		
		
		rem Проверка существования массива
		call :array_notdefined !__2! __errors
		
		rem Если есть ошибки, то выходим
		if not !__errors!==0 goto :eof

		rem Проверка индексов
		if "!__3!"=="" (
			echo Не указан набор индексов
			goto :eof
		)
		
		rem Имя массива с префиксом
		set __name=array_!__2!
	
	
		rem Приводим набор к цисловому набору вида ;54;2;3;5;
		call :to_intset "!__3!" __indexes

		rem Получаем размер
		call :set __count !__name!_count
		set /a __maxindex=__count-1
		
		rem Количество удаленных элементов
		rem Используется для поправки размера, и, главное, для смещения индексов
		set /a __deleted=0
		
		rem Пересчёт индексов
		rem Идея состоит в том, что мы бежим по исходному массиву, и если попадаем в позицию
		rem которую нужно удалить, то в текущую позицию помещаем элемент, который будет идти
		set __exit_i_loop=0
		for /l %%i in (0,1,!__maxindex!) do (
			if not !__exit_i_loop!==1 (

				rem Индекс элемента в исходном массиве, соответствущий данному положению
				set /a __newindex=%%i+!__deleted!
				set __exit_j_loop=0
				
				rem Пробегаемся по индексам вперёд, пока будут попадаться индексы элементов
				rem которых требуется удалить.
				for /l %%j in (!__newindex!,1,!__maxindex!) do (
					if not !__exit_j_loop!==1 (
					
						rem Если в наборе индексов к удалению содержится текущий, то
						rem он подлежит удалению, а значит индексы в результирующем массиве
						rem далее будут отставать от соответствующих в исходном на ещё одну позицию больше
						call :str_contains __indexes %%j __localresult
						if !__localresult!==1 (
							set /a __deleted+=1
						) else (
							set __exit_j_loop=1
						)
						
					)
					
								
				)
				
				rem Пересчитываем, чтобы понять, нужно ли дальше бежать, или нет
				set /a __newindex=%%i+!__deleted!
				if !__newindex! GTR !__maxindex! (
					set __exit_i_loop=1
				) else (
					call :set !__name!_%%i !__name!_!__newindex!
				)
			
			)
		)
		
		set /a !__name!_count=!__count!-!__deleted!
		
		rem Удаление последнего элемента (он был перемещёт на позицию вверх)
		set !_name!_!__nextindex!=
		
	rem == add ==
	rem Добавить элемент в конец массива или набор элементов
	rem call :array add имя_массива значение
	rem call :array add имя_массива набор !
	rem Чтобы добавить набор, необходимо указать параметр !
	rem Можно использовать вместо последней конструкции вызов процедуры expand
	) else if /I "!__1!"=="add" (
		
		rem Имя массива
		if "!__2!"=="" (
			echo Не указано имя массива
			goto :eof
		)
		
		rem Значение
		if "!__3!"=="" (
			echo Не задано значение. Значение не может быть пустым
			goto :eof
		)
		
		rem Пареметр l указывает на то, что добавляется набор
		if /i "!__4!"=="!" (
			call :array expand !__2! "!__3!"
			goto :eof
		)
						
		rem Проверка существования массива
		call :array_notdefined !__2! __errors
		
		rem Если есть ошибки, то выходим
		if not !__errors!==0 goto :eof
		
		rem Имя массива с префиксом
		set __name=array_!__2!
		
		rem Получаем размер
		call :set __count !__name!_count
		rem Задаём значение
		set !__name!_!__count!=!__3!
		rem и увеличиваем размер
		set /a !__name!_count+=1
		
		
	rem == expand ==
	rem Добавить набор элементов в конец массива
	rem call :array expand имя_массива набор элементов
	rem Пример:		call :array expand myArr "'first line' 'Вторая строка' 12 54"
	rem		добавление к массиву myArr 4х элементов
	) else if /I "!__1!"=="expand" (
	
		rem Имя массива
		if "!__2!"=="" (
			echo Не указано имя массива
			goto :eof
		)
		
		rem Набор
		if "!__3!"=="" (
			echo Не указан набор элементов. Набор не может быть пустым
			goto :eof
		)
		
		rem Проверка существования массива
		call :array_notdefined !__2! __errors
		
		rem Если есть ошибки, то выходим
		if not !__errors!==0 goto :eof
		
		rem Имя массива с префиксом
		set __name=array_!__2!
		
		rem Получаем размер
		call :set __count !__name!_count
		
		rem Заменяем одинарные кавычки на двойные
		set __3=!__3:'="!
		
		rem Создаем последовательно каждый элемент и присваиваем значение, начиная с последнего
		set /a __i=!__count!
		for %%i in (!__3!) do (
			rem ~ - убираем кавычки, которые необходимы для группировки
			set !__name!_!__i!=%%~i
			set /a __i+=1
		)
		set /a !__name!_count=!__i!
		
		
	rem == copy ==
	rem Копирование массива
	rem call :array copy имя_копируемого имя_конечного
	) else if /I "!__1!"=="copy" (
		
		rem Имя исходного массива
		if "!__2!"=="" (
			echo Не указано имя исходного массива
			goto :eof
		)
		
		rem Имя целевого массива
		if "!__3!"=="" (
			echo Не указано имя целевого массива
			goto :eof
		)
		
		rem Проверка существования массива
		call :array_notdefined !__2! __errors
		
		rem Если есть ошибки, то выходим
		if not !__errors!==0 goto :eof
		
		
		rem Имена массивов с префиксом
		set _name=array_!__2!
		set _name_new=array_!__3!
		
		rem Получаем размер
		call :set _count !_name!_count
		set /a _maxindex = !_count!-1
		
		rem Удаляем целевой массив, если существует
		call :array_del_ifdef !__3!

		
		rem Копируем поэлементно
		for /l %%i in (0,1,!_maxindex!) do (
			call :set !_name_new!_%%i !_name!_%%i
		)
		
		rem Копируем размер
		set /a !_name_new!_count=!_count!
	
		rem Удаляем локальные переменные
		set _name=
		set _name_new=
		set _count=
		set _maxindex=
		
	rem == each ==
	rem Вызов комманды для каждого элемента массива
	rem В качество подстановок используйте: 
	rem 	При вызове комманды:
	rem 		_i_ - индекс текущего элемента
	rem 		_val_ - значение текущего элемента
	rem 		call :array each имя_массива комманда x
	rem 
	rem 		Пример:
	rem 			call :array new B "1 4 1 6 6 2"
	rem 			set sum=0
	rem 			call :array each B "set /a sum+=_val_" x
	rem 			echo !sum!
	rem 		Выведет 20 - сумма всех элементов в массива
	rem		При вызове процедуры:
	rem			%~1	- значение (~ - убираем кавычки)
	rem			%2	- номер индекса
	rem
	rem			Пример:
	rem				call :array new B "1 4 1 6 6 2"
	rem				call :array each B to_string
	rem				echo !str!
	rem				:to_string
	rem					set str=!str!%~1
	rem				goto :eof
	rem 		Выведет 141662
	
	) else if /I "!__1!"=="each" (
	
		rem Имя массива
		if "!__2!"=="" (
			echo Не указано имя исходного массива
			goto :eof
		)
	
		rem Проверка существования массива
		call :array_notdefined !__2! __errors
		
		rem Если есть ошибки, то выходим
		if not !__errors!==0 goto :eof
		
		
		rem Комманда
		if "!__3!"=="" (
			echo Не задана камманда each
			goto :eof
		)
		
		set __is_command=0
		if /i "!__4!"=="x" (
			set __is_command=1
		)
		
		set __command=!__3!
		
		rem Имя массива с префиксом
		set __name=array_!__2!
		
		rem Получаем размер
		call :set __count !__name!_count
		set /a __maxindex = !__count!-1
		
		for /l %%i in (0,1,!__maxindex!) do (
			call :set _val_ !__name!_%%i
			
			if !__is_command!==1 (
				call :str_replace __command _i_ %%i __exec
				call :str_replace __exec _val_ "!_val_!"
				!__exec!
			) else (
				call :!__command! "!_val_!" %%i
			)
			
		)
		
		
	rem == sort ==
	rem Сортировка массива
	rem Укажите параметр R для сортировки в обратном порядке
	rem call :array sort имя_массива
	rem call :array sort имя_массива R   - сортировка в обратном порядке
	) else if /I "!__1!"=="sort" (
	
		rem Имя массива
		if "!__2!"=="" (
			echo Не указано имя исходного массива
			goto :eof
		)
	
		rem Проверка существования массива
		call :array_notdefined !__2! __errors
		
		rem Если есть ошибки, то выходим
		if not !__errors!==0 goto :eof
		
		
		rem Реверсивная сортировка
		if /I "!__3!"=="R" (
			set _rev=/r
		)
		
		
		set _shortname=!__2!
		rem Имя массива с префиксом
		set _name=array_!__2!
		
		rem Генерируем имя для временного файла
		set _tmpfile=%TMP%\array_sort_%random%%random%

		rem Сохраняем массив в файл
		call :array list !_shortname! > "!_tmpfile!.txt"
		
		rem Сортируем из файла
		sort !_rev! !_tmpfile!.txt /o "!_tmpfile!_sorted.txt"
		
		rem Удаляем текущиий массив - можно не удалять, потому что размер останется таким же
		rem и все переменные просто перезапишутся
		rem call :array delete !_shortname!
		
		rem Читаем результат из файла
		call :array load_unsafe !_shortname! "!_tmpfile!_sorted.txt"
		
		rem Удаляем временные файлы
		del /f /q "!_tmpfile!_sorted.txt" "!_tmpfile!.txt"
		
		
		rem Удаляем локальные переменные
		set _name=
		set _tmpfile=
		set _shortname=
		set _rev=
		
		
	rem == find ==
	rem Поиск элемента
	rem Возвращает номер первого найденного элемента или -1, если не найдено
	rem Используёте параметр I для игнорирования регистра
	rem call :array find имя_массива искомый_элемент N [имя_целевой_переменной=_l] - N - лобой символ, отличный от i
	rem call :array find имя_массива искомый_элемент I [имя_целевой_переменной=_l]  - поиск с игнорированием регистра
	rem Пример: call :array find myArr "Себастьян Перейро" N sebastNum
	rem возвращает в переменную sebastNum номер элемента в массиве myArr, содержащий строку Себастьян Перейро с учётом регистра
	rem N - любой символ, кроме I, чтобы не включить игнорирование регистра
	) else if /i "!__1!"=="find" (
	
		rem Имя массива
		if "!__2!"=="" (
			echo Не указано имя исходного массива
			goto :eof
		)
	
		rem Проверка существования массива
		call :array_notdefined !__2! __errors
		
		rem Если есть ошибки, то выходим
		if not !__errors!==0 goto :eof
		
		rem Значение
		if "!__3!"=="" (
			echo Не задано значение. Значение не может быть пустым
			goto :eof
		)
		set __find=!__3!
		
		rem Имя массива с префиксом
		set __name=array_!__2!
		
		rem Игнорирование регистра
		if /i "!__4!"=="I" (
			set __ignorecase=1
		)
		
		rem Имя целевой переменной
		set __var=_l
		if not "!__5!"=="" (
			set __var=!__5!
		)
		
		rem Получаем размер
		call :set __count !__name!_count
		set /a __maxindex=__count-1
		
		rem Устанавливаем результат -1
		set !__var!=-1
		
		set __exit_loop=0
		for /l %%i in (0,1,!__maxindex!) do (
			if not !__exit_loop!==1 (
				rem Читаем значение элемента
				call :set __value !__name!_%%i
				rem Сравниваем со строкой поиска с ignorecase
				rem Постановка флага как переменной вызывает ошибку
				if !__ignorecase!==1 if /i "!__value!"=="!__find!" (
						set __exit_loop=1
						set !__var!=%%i
				)
				
				if not !__ignorecase!==1 if "!__value!"=="!__find!" (
						set __exit_loop=1
						set !__var!=%%i
				)
			)
		)
		
		
	)
	call :clear_local

goto :eof



rem Копирует значение одной переменной в другую
rem Плюс в том, что имя переменной, значение которой извлекается, может быть составным
rem call :set имя_целевой_переменной имя_переменной_содержищее_значение
:set
	set %~1=!%~2!
goto :eof

rem Удаление локальных переменных (начинаются с __)
:clear_local
	rem Устанавливаю переменную __, чтобы set __ не возвращал "Переменная среды __ не определена"
	set __=0
	for /F "usebackq delims==" %%i in (`set __`) do set %%i=
goto :eof


:array_del_ifdef
	call :array_notdefined %1 __array_del_ifdef_result H
	if !__array_del_ifdef_result!==0 call :array delete %1
goto :eof

rem Проверка существования массива
:array_notdefined
	rem Устанавливаем имя целевой переменной
	set __var=_l
	
	rem Тихая проверка - не выводить сообщение
	set __hide=0
	
	if not "%2"=="" (
		set __var=%2
	)
	
	if /i "%3"=="h" (
		set __hide=1
	)
	
	if not defined !__var! set /a !__var!=0
	
	rem Проверка существования переменной, содержащей размер
	if not defined array_%~1_count (
		if not !__hide!==1 echo Массив %~1 не определен
		set /a !__var!+=1
	)
	
goto :eof

rem Перевод набора индексов к виду ;1;62;2;5;6;
rem чтобы можно было выполнять проверку наличия числа: ;%i%;
rem call :to_intset набор [имя_целевой_переменной=_l]
rem Пример:
rem call :to_intset "1 4 76 , 56, 34 ,6" set
rem echo %set%
rem выведет: ;1;4;76;56;34;6;
:to_intset
	rem Устанавливаем имя целевой переменной
	set __var=_l
	
	if not "%2"=="" (
		set __var=%2
	)
	
	rem Добавляем елементы набора к строке
	set __intset=
	for %%i in (%~1) do (
			set __intset=!__intset!;%%i
	)
	
	rem Закрывающая ;
	set __intset=!__intset!;
	
	rem Записываем результат
	call :set !__var! __intset
	
	set __intset=
	
goto :eof


rem Является ли значение(!) числом
rem call :is_number значение [имя_целевой_переменной=_l]
:is_number
	rem Устанавливаем имя целевой переменной
	set _var=_l
	
	if not "%2"=="" (
		set _var=%2
	)
	
	set _val=%~1
	set _newval=%~1
	rem Выход из цикла, а заодно и индикатор, потому что
	rem Если из цикла был совершён вынужденный выход, то значит число
	set _exit_loop_local=0

	rem Трюк в том, чтобы вырезать все цифры, и если останется пустая строка, то значит было число
	rem Подобную реализацию видел на каком-то сайте, посвящённом быдлокодерам, но вот здесь пригодилось
	for /l %%i in (0,1,9) do (
		if not !_exit_loop_local!==1 (
			rem Новое имя с новой подстановкой текущей цифры
			set _newname="_newval:%%i="
			call :set _newval !_newname!
			
			if "!_newval!"=="" (
				set _exit_loop_local=1
			)
		)
	)
	
	rem Записываем результат
	set !_var!=!_exit_loop_local!
	
	set _var=
	set _exit_loop_local=
	set _val=
	set _newval=
	set _newname=
	set _name=
		
goto :eof
rem Есть путь быстрее, но в случае передачи строки выводится сообщение об ошибке, 
rem которое никак не перехватить, однако определение всё же происходит
rem set __tmp=
rem set /a __tmp=%1
rem if not defined __tmp (
rem 	echo string
rem ) else (
rem		echo number
rem )



rem Замена подстроки
rem call :str_replace имя_исходной_переменной искомая_строка подстановка [имя_целевой_переменной=имя_исходной_переменной]
rem set str=Привет, Маша. Как дела?
rem call :str_replace str "как дела" "Как настроение" str2
rem echo !str2!
rem Результат: Привет, Маша. Как настроение?
:str_replace
	rem Устанавливаем имена целевой и исходной переменных
	set _var=%1
	set _result=%1
	
	rem Искомая строка
	set _from=%~2
	rem Строка подстановка
	set _to=%~3
	
	if not "%4"=="" (
		set _result=%4
	)
	
	set _newvarname=!_var!:!_from!=!_to!
	call :set !_result! "!_newvarname!"
	
	set _var=
	set _result=
	set _from=
	set _to=
	set _newvarname=
goto :eof

rem Проверка наличия цисла в наборе
rem Набор должен иметь вид ;3;645;12;56;7;0;
rem В целевой переменной будет 1 в случае успеха, и 0 в противном случае
rem call :str_contains имя_переменной_с_набором число [целевая_переменная=_el]
:str_contains
	rem Устанавливаем имя целевой переменной
	set _var=_l
	
	if not "%3"=="" (
		set _var=%3
	)
	
	
	rem Новое имя переменной с подстановкой. имя_переменной:;число;=#
	rem таким образом заменяем число, окруженное ; на решётку
	set _newstr=%1:;%2;=#
	
	call :set _newstr "!_newstr!"

	rem Если число присутствует, то новое значение не совпадёт состарым, 
	rem т.к. в новом искомое число будет заменено на решётку
	if not "!_newstr!"=="!%1!" (
		set !_var!=1
	) else (
		set !_var!=0
	)
	
	set _var=
	set _newstr=
goto :eof

:exit
ENDLOCAL