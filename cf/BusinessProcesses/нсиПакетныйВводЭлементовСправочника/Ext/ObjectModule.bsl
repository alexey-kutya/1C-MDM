﻿#Область ОбработчикиСобытий

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)

	Если ТипЗнч(ДанныеЗаполнения) = Тип("ЗадачаСсылка.ЗадачаИсполнителя") Тогда
		ВедущаяЗадача = ДанныеЗаполнения;
	ИначеЕсли ТипЗнч(ДанныеЗаполнения) = Тип("Структура") Тогда 
	ИначеЕсли ДанныеЗаполнения <> Неопределено Тогда 
		ИмяСправочника = ДанныеЗаполнения.Метаданные().Имя;
	КонецЕсли;

КонецПроцедуры

Процедура ПриКопировании(ОбъектКопирования)
	
	Предметы.Очистить();
	
КонецПроцедуры


#КонецОбласти

#Область СлужебныеПроцедурыИФункции

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТКА УСЛОВИЙ

Процедура ЕстьОшибкиПроверкаУсловия(ТочкаМаршрутаБизнесПроцесса, Результат)
	ЕстьОшибки = Предметы.Найти(Перечисления.нсиСтатусыОбработкиЗаявок.ЕстьОшибки,"Статус")<>Неопределено;
	Результат = ЕстьОшибки;
	
	Если Результат Тогда 
		ОтменитьПрохождение(Перечисления.нсиШагиБП.Обработка);
		ОтменитьПрохождение(Перечисления.нсиШагиБП.Утверждение);
	КонецЕсли;
КонецПроцедуры

Процедура НадоУточнитьПроверкаУсловия(ТочкаМаршрутаБизнесПроцесса, Результат)
	Результат = Предметы.Найти(Перечисления.нсиСтатусыОбработкиЗаявок.НадоУточнить,"Статус")<>Неопределено;
КонецПроцедуры

Процедура ОтклонитьЗаявкуПроверкаУсловия(ТочкаМаршрутаБизнесПроцесса, Результат)
	Результат = Предметы.Найти(Перечисления.нсиСтатусыОбработкиЗаявок.Отклонено,"Статус")<>Неопределено;
КонецПроцедуры

Процедура ОтозватьЗаявкуПроверкаУсловия(ТочкаМаршрутаБизнесПроцесса, Результат)
	Отозвано = Истина;
	Для Каждого СТрока Из Предметы Цикл 
		Отозвано = Отозвано И Строка.Статус = Перечисления.нсиСтатусыОбработкиЗаявок.Отозвано;
	КонецЦикла;
	
	Результат = Отозвано;
КонецПроцедуры

Процедура ОтклонитьЗаявкуСовсемПроверкаУсловия(ТочкаМаршрутаБизнесПроцесса, Результат)
	Результат = Истина;
	Для Каждого Строка Из Предметы Цикл 
		Результат = Результат И (
			Строка.Статус = Перечисления.нсиСтатусыОбработкиЗаявок.Отозвано
			ИЛИ Строка.Статус = Перечисления.нсиСтатусыОбработкиЗаявок.Отклонено
		);
	КонецЦикла;
КонецПроцедуры

Процедура УсловиеЕстьЭтапыДиспетчеризацииПроверкаУсловия(ТочкаМаршрутаБизнесПроцесса, Результат)
	СтрокиЭтапов = ПрохождениеЭтапов.НайтиСтроки(
		новый Структура("Шаг,Пройден",
			Перечисления.нсиШагиБП.РаспределениеЗадач,
			Ложь
		)
	);
	Результат = СтрокиЭтапов.Количество()>0;
КонецПроцедуры

Процедура УсловиеЕстьЭтапыОбработкиПроверкаУсловия(ТочкаМаршрутаБизнесПроцесса, Результат)
	СтрокиЭтапов = ПрохождениеЭтапов.НайтиСтроки(
		новый Структура("Шаг,Пройден",
			Перечисления.нсиШагиБП.Обработка,
			Ложь
		)
	);
	Результат = СтрокиЭтапов.Количество()>0;
КонецПроцедуры

Процедура УсловиеЕстьЭтапыУтвержденияПроверкаУсловия(ТочкаМаршрутаБизнесПроцесса, Результат)
	СтрокиЭтапов = ПрохождениеЭтапов.НайтиСтроки(
		новый Структура("Шаг,Пройден",
			Перечисления.нсиШагиБП.Утверждение,
			Ложь
		)
	);
	Результат = СтрокиЭтапов.Количество()>0;
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ВЫПОЛНЕНИЕ ОБРАБОТОК

Процедура СоздатьЭлементСправочникаОбработка(ТочкаМаршрутаБизнесПроцесса)
	
	КлючеваяОперация_ЗавершениеЗаявки = "Завершение заявки на пакетный ввод элементов справочника """+Строка(ИмяСправочника)+"""";
	ВремяНачала_ЗавершениеЗаявки = ОценкаПроизводительностиКлиентСервер.НачатьЗамерВремени(КлючеваяОперация_ЗавершениеЗаявки);
	ДополнительныеСвойства.Вставить("ВремяНачала_ЗавершениеЗаявки",ВремяНачала_ЗавершениеЗаявки);
	ДополнительныеСвойства.Вставить("КлючеваяОперация_ЗавершениеЗаявки",КлючеваяОперация_ЗавершениеЗаявки);
	
	УстановитьПривилегированныйРежим(Истина);
	
	Для Каждого СтрокаТЧ Из Предметы Цикл 
		
		КлючеваяОперация_СозданиеЭлементов = "Создание элемента справочника по заявке на пакетный ввод (справочник """+Строка(ИмяСправочника)+""")";
		ВремяНачала_СозданиеЭлементов = ОценкаПроизводительностиКлиентСервер.НачатьЗамерВремени(КлючеваяОперация_СозданиеЭлементов);
		
		Предмет = СтрокаТЧ.Предмет;
		
		Если СтрокаТЧ.Статус = Перечисления.нсиСтатусыОбработкиЗаявок.Отозвано
			ИЛИ СтрокаТЧ.Статус = Перечисления.нсиСтатусыОбработкиЗаявок.Отклонено Тогда 
			РегистрыСведений.нсиСтатусыОбработкиСправочников.УстановитьСтатусСправочника(Предмет,
				Новый Структура("Пользователь,ВременныйЭлемент,СозданаЗаявка", Неопределено, Истина,Ложь));
			Продолжить;
		КонецЕсли;	
		
		// записывается статус
		РегистрыСведений.нсиСтатусыОбработкиСправочников.УстановитьСтатусСправочника(Предмет,
			Новый Структура("Пользователь,ВременныйЭлемент,СозданаЗаявка,Обработано", Неопределено, Ложь,Ложь,Истина));
			
		ПредметОбъект = Предмет.ПолучитьОбъект();
		
		ПредметОбъект.ЭтоМакет = ложь;
		ПредметОбъект.Записать();
		
		ОценкаПроизводительностиКлиентСервер.ЗакончитьЗамерВремени(КлючеваяОперация_СозданиеЭлементов,ВремяНачала_СозданиеЭлементов);	
	
	КонецЦикла;
	
	Исполнитель = Справочники.Пользователи.ПустаяСсылка();

	УстановитьПривилегированныйРежим(Ложь);
	
КонецПроцедуры

Процедура УдалитьМакетЭлементаСправочникаОбработка(ТочкаМаршрутаБизнесПроцесса)
	
	КлючеваяОперация_ЗавершениеЗаявки = "Завершение заявки на пакетный ввод элементов справочника """+Строка(ИмяСправочника)+"""";
	ВремяНачала_ЗавершениеЗаявки = ОценкаПроизводительностиКлиентСервер.НачатьЗамерВремени(КлючеваяОперация_ЗавершениеЗаявки);
	ДополнительныеСвойства.Вставить("ВремяНачала_ЗавершениеЗаявки",ВремяНачала_ЗавершениеЗаявки);
	ДополнительныеСвойства.Вставить("КлючеваяОперация_ЗавершениеЗаявки",КлючеваяОперация_ЗавершениеЗаявки);
	
	УстановитьПривилегированныйРежим(Истина);
	
	Для Каждого СтрокаТЧ Из Предметы Цикл 
		Если Не СтрокаТЧ.Статус = Перечисления.нсиСтатусыОбработкиЗаявок.Отозвано
			И НЕ СтрокаТЧ.Статус = Перечисления.нсиСтатусыОбработкиЗаявок.Отклонено Тогда 
			Продолжить;
		КонецЕсли;	
		
		Предмет = СтрокаТЧ.Предмет;
	
		Если Не ЗначениеЗаполнено(Предмет) Тогда 
			Возврат;
		КонецЕсли;	
		
		Блокировка = Новый БлокировкаДанных;
		Если ТипЗнч(ИмяСправочника) = Тип("Строка") Тогда 
			ЭлементБлокировки = Блокировка.Добавить("Справочник."+ИмяСправочника);
		Иначе
			ИмяСправочникаУХ = нсиУниверсальноеХранилищеПовтИсп.ПолучитьИмяСправочникаХранилища(ИмяСправочника);
			ЭлементБлокировки = Блокировка.Добавить("Справочник."+ИмяСправочникаУХ);
		КонецЕсли;
		ЭлементБлокировки.УстановитьЗначение("Ссылка",Предмет); 
		ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
		Блокировка.Заблокировать();
		
		НовыйПредмет = Предмет.ПолучитьОбъект();
		НовыйПредмет.УстановитьПометкуУдаления(Истина);
		
		РегистрыСведений.нсиСтатусыОбработкиСправочников.УстановитьСтатусСправочника(Предмет,
			Новый Структура("Пользователь,ВременныйЭлемент,СозданаЗаявка", Неопределено, Истина,Ложь));
			
	КонецЦикла;	
		
	Исполнитель = Справочники.Пользователи.ПустаяСсылка();
	
	УстановитьПривилегированныйРежим(Ложь);
	
КонецПроцедуры

Процедура ЗавершениеПриЗавершении(ТочкаМаршрутаБизнесПроцесса, Отказ)
	ДатаЗавершения = ТекущаяДата();
	нсиБизнесПроцессы.ОтправитьОповещениеОЗавершенииБП(Ссылка);
	Исполнитель = Справочники.Пользователи.ПустаяСсылка();
	
	УстановитьПривилегированныйРежим(Истина);
	Записать();
	
	ОценкаПроизводительностиКлиентСервер.ЗакончитьЗамерВремени(
		ДополнительныеСвойства.КлючеваяОперация_ЗавершениеЗаявки,
		ДополнительныеСвойства.ВремяНачала_ЗавершениеЗаявки
	);	

КонецПроцедуры

Процедура ПриУстановкеНовогоНомера(СтандартнаяОбработка, Префикс)
	СтандартнаяОбработка = Ложь;
	Номер = (Формат(нсиБизнесПроцессы.ПолучитьНовыйНомер("НумераторБП"),"ЧЦ=9; ЧВН=; ЧГ=0"));
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// СОБЫТИЯ ЗАДАЧ

Процедура ЗадачаПриВыполнении(ТочкаМаршрутаБизнесПроцесса, Задача, Отказ)
	РезультатВыполнения = РезультатВыполненияДляТочек(Задача, ТочкаМаршрутаБизнесПроцесса.Имя) + РезультатВыполнения;
	
	ТребуетсяУточнить = Предметы.Найти(Перечисления.нсиСтатусыОбработкиЗаявок.НадоУточнить,"Статус")<>Неопределено;
	ЗаявкаОтклонена = 	Предметы.Найти(Перечисления.нсиСтатусыОбработкиЗаявок.Отклонено,"Статус")<>Неопределено;
	Если НЕ ТребуетсяУточнить 
		И НЕ (
			ТочкаМаршрутаБизнесПроцесса = БизнесПроцессы.нсиИзменениеЭлементаСправочника.ТочкиМаршрута.НазначениеОтветственного 
			И ЗаявкаОтклонена
		) Тогда 
		СтрокаЭтапа = ПрохождениеЭтапов.НайтиСтроки(новый Структура("Шаг,НомерЭтапа",Задача.ШагБП,Задача.НомерЭтапаБП));
		Если СтрокаЭтапа.Количество()>0 Тогда 
			СтрокаЭтапа[0].Пройден = Истина;
		КонецЕсли;
	КонецЕсли;
	
	ЗадачаОбъект = Задача.ПолучитьОбъект();
	ЗадачаОбъект.ДатаИсполнения = ТекущаяДата();
	
	ЗадачаОбъект.ДлительностьИсполнения 	= 
		нсиБизнесПроцессы.ОпределитьДлительностьПоГрафику(
			Задача.ДатаНачала,
			Задача.ДатаИсполнения,
			Задача.Исполнитель
	);
	ЗадачаОбъект.Записать();
	
	УстановитьПривилегированныйРежим(Истина);
	Записать();
КонецПроцедуры

Функция ПолучитьШагЭтапИсполнителя(ТочкаМаршрутаБизнесПроцесса)
	Результат = новый Структура(
		"Шаг,
		|НомерЭтапа,
		|СпособРаспределения,
		|РольИсполнителя,
		|Исполнитель,
		|ОсновнойОбъектАдресации,
		|ВремяИсполнения,
		|ВремяОповещения"
	);
	
	МножительВремениОбработки = 1;
	
	СтрокиОтозвано = Предметы.НайтиСтроки(Новый Структура("Статус",Перечисления.нсиСтатусыОбработкиЗаявок.Отозвано));
	СтрокиПроверено = Предметы.НайтиСтроки(Новый Структура("Статус",Перечисления.нсиСтатусыОбработкиЗаявок.ПроверенаКлассификация));
	
	Если ТочкаМаршрутаБизнесПроцесса = БизнесПроцессы.нсиПакетныйВводЭлементовСправочника.ТочкиМаршрута.НазначениеОтветственного Тогда 
		Результат.Шаг = Перечисления.нсиШагиБП.РаспределениеЗадач;
		МножительВремениОбработки = Предметы.Количество() - СтрокиОтозвано.Количество();
	ИначеЕсли ТочкаМаршрутаБизнесПроцесса = БизнесПроцессы.нсиПакетныйВводЭлементовСправочника.ТочкиМаршрута.ОбработкаИнформации Тогда 
		Результат.Шаг = Перечисления.нсиШагиБП.Обработка;
		МножительВремениОбработки = Предметы.Количество() - СтрокиОтозвано.Количество()-СтрокиПроверено.Количество();
	ИначеЕсли ТочкаМаршрутаБизнесПроцесса = БизнесПроцессы.нсиПакетныйВводЭлементовСправочника.ТочкиМаршрута.КонтрольИсполнения Тогда 
		Результат.Шаг = Перечисления.нсиШагиБП.Утверждение;
		МножительВремениОбработки = Предметы.Количество() - СтрокиОтозвано.Количество();
	ИначеЕсли ТочкаМаршрутаБизнесПроцесса = БизнесПроцессы.нсиПакетныйВводЭлементовСправочника.ТочкиМаршрута.УточнениеИнформации Тогда 
		Результат.Шаг = Перечисления.нсиШагиБП.ПустаяСсылка();
		Результат.НомерЭтапа = 0;
		Результат.РольИсполнителя = Справочники.РолиИсполнителей.ПустаяСсылка();
		Результат.Исполнитель = Автор;
		Результат.ОсновнойОбъектАдресации = Неопределено;
		Результат.ВремяИсполнения = 0;
		Результат.ВремяОповещения = 0;
		Возврат Результат;
	КонецЕсли;
	
	нсиБизнесПроцессы.ЗаполнитьПараметрыЭтапа(ЭтотОбъект,Результат,Макс(МножительВремениОбработки,1));
	Возврат Результат;
		
КонецФункции

Процедура ЗаполнениеПриСозданииЗадач(ТочкаМаршрутаБизнесПроцесса, ФормируемыеЗадачи, Отказ)
	
	Для Каждого Задача Из ФормируемыеЗадачи Цикл
		
		Задача.Автор 			= Автор;
		Задача.Наименование 	= ""+ТочкаМаршрутаБизнесПроцесса+": "+Наименование;
		Задача.ДатаНачала = ТекущаяДата();
		
		Если ТочкаМаршрутаБизнесПроцесса = БизнесПроцессы.нсиПакетныйВводЭлементовСправочника.ТочкиМаршрута.УточнениеИнформации Тогда 
			Задача.Исполнитель 		= Автор;
			Исполнитель = Автор;
			Задача.РольИсполнителя  = Автор;
			Задача.СпособРаспределения = Перечисления.нсиСпособыРаспределенияЗадач.ПустаяСсылка();
		Иначе
			Структура = ПолучитьШагЭтапИсполнителя(ТочкаМаршрутаБизнесПроцесса);
			Задача.Исполнитель 		= Структура.Исполнитель;
			Исполнитель = Структура.Исполнитель;
			Задача.РольИсполнителя  = Структура.РольИсполнителя;
			Задача.ШагБП            = Структура.Шаг;
			Задача.НомерЭтапаБП     = Структура.НомерЭтапа;
			Задача.ОсновнойОбъектАдресации = Структура.ОсновнойОбъектАдресации;
			Задача.СпособРаспределения = Структура.СпособРаспределения;
			Задача.СрокИсполнения 	= 
				нсиБизнесПроцессы.ОпределитьДатуОкончанияПоКалендарномуГрафику(
					Задача.ДатаНачала,
					Структура.ВремяИсполнения,
					Структура.Исполнитель
			);
			Задача.СрокОповещения 	= 
				нсиБизнесПроцессы.ОпределитьДатуОкончанияПоКалендарномуГрафику(
					Задача.ДатаНачала,
					Структура.ВремяОповещения,
					Структура.Исполнитель
			);
		КонецЕсли;
		
		Для Каждого СтрокаТЧ Из Предметы Цикл 
			РегистрыСведений.нсиСтатусыОбработкиСправочников.УстановитьСтатусСправочника(СтрокаТЧ.Предмет,
				Новый Структура("Пользователь,ВременныйЭлемент,СозданаЗаявка", Исполнитель, Истина,Истина));
		КонецЦикла;	
		
		нсиБизнесПроцессы.ОтправитьОповещениеПоЭлектроннойПочте(Задача);
		
	КонецЦикла;
	
	УстановитьПривилегированныйРежим(Истина);
	Записать();
	
КонецПроцедуры

// Функция - возвращает результат выполнения для точки по шаблону.
//
Функция РезультатВыполненияДляТочек(Знач ЗадачаСсылка, ПеренаправитьЗадачи = Неопределено) Экспорт
	
#Если Сервер ИЛИ ВнешнееСоединение тогда	
	СтрокаФормат = НСтр("en='%1,%2 treated task %4:"
"%3';ru='%1, %2 обработал(а) задачу %4:"
"%3"
"'");
		
	ЗадачаДанные = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(ЗадачаСсылка, 
		"РезультатВыполнения,ДатаИсполнения,Исполнитель");
	Комментарий = СокрЛП(ЗадачаДанные.РезультатВыполнения);
	Комментарий = ?(ПустаяСтрока(Комментарий), "", Комментарий + Символы.ПС);
	
	РезультатОбработки = "";
	
	Отклонено = Предметы.Найти(Перечисления.нсиСтатусыОбработкиЗаявок.Отклонено,"Статус")<>Неопределено;
	ЕстьОшибки = Предметы.Найти(Перечисления.нсиСтатусыОбработкиЗаявок.ЕстьОшибки,"Статус")<>Неопределено;
	НадоУточнить = Предметы.Найти(Перечисления.нсиСтатусыОбработкиЗаявок.НадоУточнить,"Статус")<>Неопределено;
	
	РезультатОбработки = "";
	Для Каждого Строка Из Предметы Цикл
		Если (Строка.Статус = ЕстьОшибки И ЗадачаСсылка.ТочкаМаршрута = БизнесПроцессы.нсиПакетныйВводЭлементовСправочника.ТочкиМаршрута.ПроверкаКлассификации)
			ИЛИ Строка.Статус = Перечисления.нсиСтатусыОбработкиЗаявок.НадоУточнить
			ИЛИ Строка.Статус = Перечисления.нсиСтатусыОбработкиЗаявок.Отклонено
			ИЛИ Строка.Статус = Перечисления.нсиСтатусыОбработкиЗаявок.Уточнено
			Тогда 
			
			РезультатОбработки = 
				РезультатОбработки + Символы.ПС+
				"Строка "+Строка(Строка.НомерСтроки)+": "+Строка(Строка.Предмет)+". "+Строка(Строка.Статус)+" ("+Строка.Комментарий+")";
		КонецЕсли;
	КонецЦикла;
	
	Результат = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(СтрокаФормат, 
	              ЗадачаДанные.ДатаИсполнения,
	              ЗадачаДанные.Исполнитель,
	              Комментарий,
				  РезультатОбработки
	);
	
	Возврат Результат;

#Иначе
	Возврат "";
#КонецЕсли
		
		
КонецФункции

// Процедура - заполняет табличную часть "Прохождение этапов"
// Заполнение осуществляется по настройке бизнес-процесса
Процедура ЗаполнитьПрохождениеЭтапов() Экспорт
	ПрохождениеЭтапов.Очистить();
	Если НЕ ЗначениеЗаполнено(НастройкаБП) Тогда 
		Возврат;
	КонецЕсли;
	
	Для Каждого Шаг Из НастройкаБП.ШагиБП Цикл 
		Этапы = НастройкаБП.ЭтапыБП.НайтиСтроки(новый Структура("Шаг",Шаг.Шаг));
		Для Каждого Этап ИЗ Этапы Цикл 
			Если НЕ ЗначениеЗаполнено(Этап.УсловиеВыполненияТипПредмета)
				ИЛИ Этап.УсловиеВыполненияТипПредмета = ИмяСправочника Тогда 
				
				НС = ПрохождениеЭтапов.Добавить();
				ЗаполнитьЗначенияСвойств(НС,Этап);
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
КонецПроцедуры

Процедура ОтменитьПрохождение(Шаг)
	СтрокиЭтапов = ПрохождениеЭтапов.НайтиСтроки(новый Структура("Шаг",Шаг));
	Для Каждого Строка Из СтрокиЭтапов Цикл 
		Строка.Пройден = Ложь;
	КонецЦикла;
КонецПроцедуры

Процедура СоздатьВременныйЭлемент(Отказ, ДанныеЗаполнения = Неопределено) Экспорт
	УстановитьПривилегированныйРежим(Истина);
	
	Если СоздатьГруппу Тогда 
		НовыйПредмет = нсиБизнесПроцессыРаботаСоСправочниками.СоздатьГруппуСправочника(ИмяСправочника);
		НовыйПредмет.Наименование = "Новая группа справочника";
	Иначе 
		НовыйПредмет = нсиБизнесПроцессыРаботаСоСправочниками.СоздатьЭлементСправочника(ИмяСправочника);
//	ITRR Кутья АА Локализация	
//		НовыйПредмет.Наименование = "Новый элемент справочника";
		НовыйПредмет.Наименование = НСтр("ru = 'Новый элемент справочника'; en = 'New item'");
	КонецЕсли;
				
	Если НовыйПредмет.Метаданные().Реквизиты.Найти("ТипПозиции") <> Неопределено Тогда 
		НовыйПредмет.ТипПозиции = Перечисления.нсиТипыПозицийСправочников.ЭталоннаяПозиция;
	КонецЕсли;
	
	Если НовыйПредмет.Метаданные().Реквизиты.Найти("ПризнакИспользования") <> Неопределено Тогда 
		НовыйПредмет.ПризнакИспользования = нсиБизнесПроцессыРаботаСоСправочниками.ПолучитьПризнакИспользованияПоУмолчанию(ИмяСправочника);
	КонецЕсли;
	
	Если ДанныеЗаполнения <> Неопределено Тогда 
		НовыйПредмет.Заполнить(ДанныеЗаполнения);
	КонецЕсли;
	
	НовыйПредмет.ЭтоМакет = Истина;
	НовыйПредмет.ДополнительныеСвойства.Вставить("СозданиеИзБП", Истина);	
	НачатьТранзакцию();
	Попытка
		СсылкаНового = нсиБизнесПроцессыРаботаСоСправочниками.ПолучитьНовуюСсылку(ИмяСправочника);
		НовыйПредмет.УстановитьСсылкуНового(СсылкаНового);
		РегистрыСведений.нсиСтатусыОбработкиСправочников.УстановитьСтатусСправочника(СсылкаНового,
					Новый Структура("Пользователь,ВременныйЭлемент,СозданаЗаявка", ПараметрыСеанса.ТекущийПользователь, Истина, Истина));
		НовыйПредмет.Записать();
		
		НС = Предметы.Добавить();
		НС.Предмет = НовыйПредмет.Ссылка;
		
		Если НЕ ЗначениеЗаполнено(Номер) Тогда 
			УстановитьНовыйНомер("");
		КонецЕсли;
		
		ОбменДанными.Загрузка = Истина;
		Записать();
		
		ЗафиксироватьТранзакцию();
	Исключение
//	ITRR Кутья АА Локализация	
//		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не удалось создать макет: "+ОписаниеОшибки(),,,,Отказ);
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(НСтр("ru = 'Не удалось создать макет:'; en = 'Could not create layout:'")+" "
		+ОписаниеОшибки(),,,,Отказ);
		ОтменитьТранзакцию();
	КонецПопытки;
	
	УстановитьПривилегированныйРежим(Ложь);
КонецПроцедуры

#КонецОбласти
