﻿#Область ОбработчикиСобытий

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	
	Если ТипЗнч(ДанныеЗаполнения) = Тип("СправочникСсылка.нсиУниверсальныйФункциональныйСправочник")
		И ДанныеЗаполнения.Владелец = Владелец 
		И ДанныеЗаполнения.пЭтоГруппа = пЭтоГруппа Тогда
		
		// заполнение реквизитов
		ЗаполнитьЗначенияСвойств(ЭтотОбъект, ДанныеЗаполнения, , "Владелец,Родитель,Код,ЭтоМакет,Идентификатор");
		
		Если пЭтоГруппа Тогда 
			Возврат;
		КонецЕсли;	
		
		// заполнение табличных частей
		ТехническиеХарактеристики.Загрузить(ДанныеЗаполнения.ТехническиеХарактеристики.Выгрузить());
		
		пМетаданные = нсиУниверсальноеХранилище.ПолучитьМетаданные(Владелец);

		ДополнительныеСвойства.Вставить("пМетаданные",пМетаданные);
		
		пОбъект = нсиУниверсальноеХранилище.ПолучитьОбъект(пМетаданные,ДанныеЗаполнения);
		ДополнительныеСвойства.Вставить("Данные",пОбъект);
		
	КонецЕсли;
КонецПроцедуры

Процедура ПередЗаписью(Отказ)
	нсиУниверсальноеХранилище.МодульОбъектаПередЗаписью(ЭтотОбъект, Отказ);
	
	Если ОбменДанными.Загрузка Тогда 
		Возврат;
	КонецЕсли; 
	
	нсиСравнениеДанныхСобытия.ПроверитьТипПозицииПередЗаписьюФункциональногоСправочника(ЭтотОбъект,Отказ);
	
	Если ЭтоМакет тогда
		ДополнительныеСвойства.Вставить("СШПНеобрабатывать", Истина); 
	КонецЕсли;	
	
	нсиОбщегоНазначения.УдалитьПробелыИзСтроки(Наименование);
	
КонецПроцедуры

Процедура ПриЗаписи(Отказ)
	Если ОбменДанными.Загрузка Тогда 
		Возврат;
	КонецЕсли; 
	
	нсиУниверсальноеХранилище.МодульОбъектаПриЗаписи(ЭтотОбъект);
КонецПроцедуры

Процедура ПередУдалением(Отказ)
	Если ОбменДанными.Загрузка Тогда 
		Возврат;
	КонецЕсли; 
	
	нсиУниверсальноеХранилище.УдалитьОбъект(Ссылка);
КонецПроцедуры

Процедура ПриКопировании(ОбъектКопирования)
	Идентификатор = Справочники.нсиУниверсальныйФункциональныйСправочник.ПустаяСсылка().УникальныйИдентификатор();
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Процедура - устанавливает для дублей новый эталон.
// храним 2х-уровневую таблицу мэппинга.
//
Процедура ПеренестиДублиКНовомуЭталону() Экспорт
	
	Если Не ТипПозиции = Перечисления.нсиТипыПозицийСправочников.ДублирующаяПозиция Тогда 
		Возврат;
	КонецЕсли;
	
	Запрос = Новый Запрос("ВЫБРАТЬ РАЗРЕШЕННЫЕ Ссылка ИЗ Справочник.нсиМТР ГДЕ ЭталоннаяПозиция = &Ссылка");
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	ВыборкаДетальныеЗаписи = Запрос.Выполнить().Выбрать();
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		
		Блокировка = Новый БлокировкаДанных;
		ЭлементБлокировки = Блокировка.Добавить("Справочник.нсиМТР");
		ЭлементБлокировки.УстановитьЗначение("Ссылка", ВыборкаДетальныеЗаписи.Ссылка);
		ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
		Блокировка.Заблокировать();         		
		
		ИзменяемыйДубль = ВыборкаДетальныеЗаписи.Ссылка.ПолучитьОбъект();
		ИзменяемыйДубль.ТипПозиции 			= Перечисления.нсиТипыПозицийСправочников.ДублирующаяПозиция;
		ИзменяемыйДубль.ЭталоннаяПозиция 	= ЭталоннаяПозиция;
		ИзменяемыйДубль.Записать();
				
	КонецЦикла;  	
	
КонецПроцедуры	

// Функция - проверяется соответствие исходных характеристик классу и устанавливаются характеристики класса.
//
Функция ПроверитьЗаполнитьТехническиеХарактеристики() Экспорт 
	
	УстановитьПривилегированныйРежим(Истина);
	
	Если Не ЗначениеЗаполнено(Класс) Тогда 
		Возврат Ложь;
	КонецЕсли;	
	
	// проверяется соответствие исходных характеристик классу
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Класс", Класс);
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.Текст = 
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ РАЗЛИЧНЫЕ
		|	нсиХарактеристикиУниверсальногоСправочника.Ссылка,
		|	ТХ.Характеристика
		|ИЗ
		|	(ВЫБРАТЬ
		|		ТХ.Характеристика КАК Характеристика
		|	ИЗ
		|		Справочник.нсиУниверсальныйФункциональныйСправочник.ТехническиеХарактеристики КАК ТХ
		|	ГДЕ
		|		ТХ.Ссылка = &Ссылка) КАК ТХ
		|		ПОЛНОЕ СОЕДИНЕНИЕ (ВЫБРАТЬ
		|			нсиХарактеристикиУниверсальногоСправочника.Ссылка КАК Ссылка
		|		ИЗ
		|			ПланВидовХарактеристик.нсиХарактеристикиУниверсальногоСправочника КАК нсиХарактеристикиУниверсальногоСправочника
		|		ГДЕ
		|			нсиХарактеристикиУниверсальногоСправочника.Класс = &Класс
		|			И нсиХарактеристикиУниверсальногоСправочника.ПометкаУдаления = ЛОЖЬ) КАК нсиХарактеристикиУниверсальногоСправочника
		|		ПО ТХ.Характеристика = нсиХарактеристикиУниверсальногоСправочника.Ссылка
		|ГДЕ
		|	(нсиХарактеристикиУниверсальногоСправочника.Ссылка ЕСТЬ NULL 
		|			ИЛИ ТХ.Характеристика ЕСТЬ NULL )";

	Результат = Запрос.Выполнить().Выгрузить();
	Если Результат.Количество() = 0 Тогда 
		Возврат Ложь;
	КонецЕсли;	

	// установка характеристик класса
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Класс", Класс);
	Запрос.УстановитьПараметр("ТехническиеХарактеристики", ЭтотОбъект.ТехническиеХарактеристики.Выгрузить());
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ТХ.Характеристика КАК Характеристика,
		|	ТХ.Значение КАК Значение
		|ПОМЕСТИТЬ ТХ
		|ИЗ
		|	&ТехническиеХарактеристики КАК ТХ
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗРЕШЕННЫЕ РАЗЛИЧНЫЕ
		|	нсиХарактеристикиУниверсальногоСправочника.Ссылка КАК Характеристика,
		|	ТХ.Значение
		|ИЗ
		|	(ВЫБРАТЬ
		|		нсиХарактеристикиУниверсальногоСправочника.Ссылка КАК Ссылка
		|	ИЗ
		|		ПланВидовХарактеристик.нсиХарактеристикиУниверсальногоСправочника КАК нсиХарактеристикиУниверсальногоСправочника
		|	ГДЕ
		|		нсиХарактеристикиУниверсальногоСправочника.Класс = &Класс) КАК нсиХарактеристикиУниверсальногоСправочника
		|		ЛЕВОЕ СОЕДИНЕНИЕ ТХ КАК ТХ
		//|		ПО (ТХ.Характеристика.НаименованиеПоКлассификатору = нсиХарактеристикиУниверсальногоСправочника.Ссылка.НаименованиеПоКлассификатору)
		|		ПО (ТХ.Характеристика = нсиХарактеристикиУниверсальногоСправочника.Ссылка)
		|АВТОУПОРЯДОЧИВАНИЕ";
		
	ТехническиеХарактеристики.Очистить();	
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		
		Если Выборка.Характеристика.ПометкаУдаления = Истина И Не ЗначениеЗаполнено(Выборка.Значение) Тогда
			Продолжить;
		КонецЕсли;
		
		Строка = ТехническиеХарактеристики.Добавить();
		ЗаполнитьЗначенияСвойств(Строка, Выборка);
		Строка.НаименованиеХарактеристики = Строка.Характеристика.НаименованиеПоКлассификатору;
		
	КонецЦикла;

	Возврат Истина;
		
КонецФункции

#КонецОбласти