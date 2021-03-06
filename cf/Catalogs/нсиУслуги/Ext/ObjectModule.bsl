﻿
#Область ОбработчикиСобытийОбъекта

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	
	Если ТипЗнч(ДанныеЗаполнения) = Тип("СправочникСсылка.нсиУслуги") Тогда
		
		// заполнение реквизитов
		ЗаполнитьЗначенияСвойств(ЭтотОбъект, ДанныеЗаполнения, , "Владелец,Родитель,Код,ЭтоМакет");
		
		Если ЭтоГруппа Тогда 
			Возврат;
		КонецЕсли;	
		
		// заполнение табличных частей
		ДополнительнаяКлассификация.Загрузить(ДанныеЗаполнения.ДополнительнаяКлассификация.Выгрузить());
		ДополнительныеРеквизиты.Загрузить(ДанныеЗаполнения.ДополнительныеРеквизиты.Выгрузить());
		ТехническиеХарактеристики.Загрузить(ДанныеЗаполнения.ТехническиеХарактеристики.Выгрузить());
		
		// заполнение регистров сведений
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("Объект", ДанныеЗаполнения.Ссылка);
		Запрос.УстановитьПараметр("ОбъектЗагрузки", Ссылка);
		Запрос.Текст = 
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ &ОбъектЗагрузки КАК Объект, Свойство, Значение
		|ИЗ РегистрСведений.ДополнительныеСведения ГДЕ Объект = &Объект"; 
		Результат = Запрос.Выполнить().Выгрузить();
		Если Не Результат.Количество() = 0 Тогда 
			НаборЗаписи = РегистрыСведений.ДополнительныеСведения.СоздатьНаборЗаписей();
			НаборЗаписи.Отбор.Объект.Установить(Ссылка);
			НаборЗаписи.Загрузить(Результат);
			НаборЗаписи.Записать(Истина); 			
		КонецЕсли;
		
	КонецЕсли;

КонецПроцедуры

Процедура ПередЗаписью(Отказ)
	Если ОбменДанными.Загрузка Тогда 
		Возврат;
	КонецЕсли;
	#Если Сервер ИЛИ ВнешнееСоединение тогда
	// СтандартныеПодсистемы.Свойства
	УправлениеСвойствами.ПередЗаписьюВидаОбъекта(ЭтотОбъект, "Справочник_нсиУслуги");
	// Конец СтандартныеПодсистемы.Свойства
	#КонецЕсли
	нсиСравнениеДанныхСобытия.ПроверитьТипПозицииПередЗаписьюФункциональногоСправочника(ЭтотОбъект,Отказ);
	
	Если ЭтоМакет тогда
		ДополнительныеСвойства.Вставить("СШПНеобрабатывать", Истина); 
	КонецЕсли;	
	
	нсиОбщегоНазначения.УдалитьПробелыИзСтроки(Наименование);
	нсиОбщегоНазначения.УдалитьПробелыИзСтроки(ПолноеНаименование);
	
КонецПроцедуры

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)

	// проверяются только эталоны
	Если НЕ ПометкаУдаления И
		ТипПозиции = Перечисления.нсиТипыПозицийСправочников.ЭталоннаяПозиция
		Тогда 
		
		// все проверки
		
	ИначеЕсли ТипПозиции = Перечисления.нсиТипыПозицийСправочников.ДублирующаяПозиция Тогда 	
		
		Если Не ЗначениеЗаполнено(ЭталоннаяПозиция) Тогда 
			Отказ = Истина;
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Для дублирующей позиции не указан эталон.",ЭтотОбъект, "ЭталоннаяПозиция");
		КонецЕсли;	
		ПроверяемыеРеквизиты.Очистить();
		ПроверяемыеРеквизиты.Добавить("Наименование");
		ПроверяемыеРеквизиты.Добавить("ТипПозиции");
		Возврат; // проверки не работают	
		
	Иначе 
		
		ПроверяемыеРеквизиты.Очистить();
		ПроверяемыеРеквизиты.Добавить("Наименование");
		ПроверяемыеРеквизиты.Добавить("ТипПозиции");
		Возврат; // проверки не работают	
		
	КонецЕсли;
	
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
	
	Запрос = Новый Запрос("ВЫБРАТЬ РАЗРЕШЕННЫЕ Ссылка ИЗ Справочник.нсиУслуги ГДЕ ЭталоннаяПозиция = &Ссылка");
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	ВыборкаДетальныеЗаписи = Запрос.Выполнить().Выбрать();
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		
		Блокировка = Новый БлокировкаДанных;
		ЭлементБлокировки = Блокировка.Добавить("Справочник.нсиУслуги");
		ЭлементБлокировки.УстановитьЗначение("Ссылка", ВыборкаДетальныеЗаписи.Ссылка);
		ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
		Блокировка.Заблокировать();         		
		
		ИзменяемыйДубль = ВыборкаДетальныеЗаписи.Ссылка.ПолучитьОбъект();
		ИзменяемыйДубль.ЭталоннаяПозиция = ЭталоннаяПозиция;
		ИзменяемыйДубль.Записать();
				
	КонецЦикла;  	
	
КонецПроцедуры	

// Функция - проверяется соответствие исходных характеристик классу и устанавливаются характеристики класса.
//
Функция ПроверитьЗаполнитьТехническиеХарактеристики() Экспорт 
	
	УстановитьПривилегированныйРежим(Истина);
	
	Если Не Константы.нсиУчитыватьВРазрезеКлассификатораУслуг.Получить() Тогда 
		Возврат Ложь;
	КонецЕсли;	
	
	Если Не ЗначениеЗаполнено(Класс) Тогда 
		Возврат Ложь;
	КонецЕсли;	
	
	// проверяется соответствие исходных характеристик классу
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Класс", Класс);
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.Текст = 
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ РАЗЛИЧНЫЕ
		|	нсиХарактеристикиУслуг.Ссылка,
		|	нсиУслугТехническиеХарактеристики.Характеристика
		|ИЗ
		|	(ВЫБРАТЬ
		|		нсиУслугТехническиеХарактеристики.Характеристика КАК Характеристика
		|	ИЗ
		|		Справочник.нсиУслуги.ТехническиеХарактеристики КАК нсиУслугТехническиеХарактеристики
		|	ГДЕ
		|		нсиУслугТехническиеХарактеристики.Ссылка = &Ссылка) КАК нсиУслугТехническиеХарактеристики
		|		ПОЛНОЕ СОЕДИНЕНИЕ (ВЫБРАТЬ
		|			нсиХарактеристикиУслуг.Ссылка КАК Ссылка
		|		ИЗ
		|			ПланВидовХарактеристик.нсиХарактеристикиУслуг КАК нсиХарактеристикиУслуг
		|		ГДЕ
		|			нсиХарактеристикиУслуг.Класс = &Класс
		|			И нсиХарактеристикиУслуг.ПометкаУдаления = ЛОЖЬ) КАК нсиХарактеристикиУслуг
		|		ПО нсиУслугТехническиеХарактеристики.Характеристика = нсиХарактеристикиУслуг.Ссылка
		|ГДЕ
		|	(нсиХарактеристикиУслуг.Ссылка ЕСТЬ NULL 
		|			ИЛИ нсиУслугТехническиеХарактеристики.Характеристика ЕСТЬ NULL )";

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
		|	нсиТехническиеХарактеристики.Характеристика КАК Характеристика,
		|	нсиТехническиеХарактеристики.Значение КАК Значение
		|ПОМЕСТИТЬ нсиТехническиеХарактеристики
		|ИЗ
		|	&ТехническиеХарактеристики КАК нсиТехническиеХарактеристики
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗРЕШЕННЫЕ РАЗЛИЧНЫЕ
		|	нсиХарактеристикиУслуг.Ссылка КАК Характеристика,
		|	нсиТехническиеХарактеристики.Значение
		|ИЗ
		|	(ВЫБРАТЬ
		|		нсиХарактеристикиУслуг.Ссылка КАК Ссылка
		|	ИЗ
		|		ПланВидовХарактеристик.нсиХарактеристикиУслуг КАК нсиХарактеристикиУслуг
		|	ГДЕ
		|		нсиХарактеристикиУслуг.Класс = &Класс) КАК нсиХарактеристикиУслуг
		|		ЛЕВОЕ СОЕДИНЕНИЕ нсиТехническиеХарактеристики КАК нсиТехническиеХарактеристики
		//|		ПО (нсиТехническиеХарактеристики.Характеристика.НаименованиеПоКлассификатору = нсиХарактеристикиУслуг.Ссылка.НаименованиеПоКлассификатору)
		|		ПО (нсиТехническиеХарактеристики.Характеристика = нсиХарактеристикиУслуг.Ссылка)
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

