﻿#Область СлужебныеПроцедурыИФункции

// Функция - возвращает количество помеченных на удаление элементов.
//
Функция НайтиПомеченные() Экспорт
	Объекты.Строки.Очистить();
	Запрос = Новый Запрос();
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Данные.ВидСправочника,
		|	Данные.ВидСправочника.Наименование КАК Наименование
		|ИЗ
		|	(ВЫБРАТЬ
		|		Виды.Ссылка КАК ВидСправочника
		|	ИЗ
		|		Справочник.нсиВидыСправочников КАК Виды
		|			ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.нсиПраваДоступаНаВидыСправочников КАК Права
		|			ПО (Права.ВидСправочника = Виды.Ссылка)
		|			ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.СоставыГруппПользователей КАК СоставГрупп
		|			ПО (СоставГрупп.ГруппаПользователей = Права.Пользователь)
		|				И (СоставГрупп.Используется)
		|	ГДЕ
		|		Виды.ВидСправочника <> ЗНАЧЕНИЕ(Перечисление.нсиВидыСправочников.ТабличнаяЧасть)
		|		И СоставГрупп.Пользователь = &ТекущийПользователь ИЛИ Права.Пользователь = &ТекущийПользователь
		|	
		|	СГРУППИРОВАТЬ ПО
		|		Виды.Ссылка
		|	
		|	ИМЕЮЩИЕ
		|		МАКСИМУМ(Права.УдалениеПомеченных) = ИСТИНА) КАК Данные
		|
		|УПОРЯДОЧИТЬ ПО
		|	Данные.ВидСправочника.Наименование";
	Запрос.УстановитьПараметр("ТекущийПользователь", ПараметрыСеанса.ТекущийПользователь);
	
	Всего = 0;
	Выб = Запрос.Выполнить().Выбрать();
	Пока Выб.Следующий() Цикл
		Всего = Всего + ДобавитьОбъектыСправочника(Выб);
	КонецЦикла;
	Возврат Всего;
КонецФункции

Функция ДобавитьОбъектыСправочника(Выборка)
	Запрос = Новый Запрос();
	Запрос.УстановитьПараметр("ВидСправочника", Выборка.ВидСправочника);
	ОсновнаяТаблица = "Справочник."+нсиУниверсальноеХранилищеПовтИсп.ПолучитьИмяСправочникаХранилища(Выборка.ВидСправочника);
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ОсновнаяТаблица.Ссылка КАК Элемент
		|ИЗ
		|	"+ОсновнаяТаблица+" КАК ОсновнаяТаблица
		|ГДЕ
		|	ОсновнаяТаблица.Владелец = &ВидСправочника
		|	И ОсновнаяТаблица.ПометкаУдаления
		|АВТОУПОРЯДОЧИВАНИЕ";
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда
		Возврат 0 ;
	КонецЕсли;
	
	Выб = Результат.Выбрать();
	
	СтрокаСправочника = Объекты.Строки.Добавить();
	СтрокаСправочника.Пометка = Истина;
	СтрокаСправочника.Текст = Строка(Выборка.ВидСправочника)+" ("+Выб.Количество()+")";
	СтрокаСправочника.ВидСправочника = Выборка.ВидСправочника;
	СтрокаСправочника.Количество = Выб.Количество();
	
	Пока Выб.Следующий() Цикл
		СтрокаЭлемента = СтрокаСправочника.Строки.Добавить();
		СтрокаЭлемента.Текст = Строка(Выб.Элемент)+" ("+Строка(Выборка.ВидСправочника)+")";
		СтрокаЭлемента.Элемент = Выб.Элемент;
		СтрокаЭлемента.ВидСправочника = Выборка.ВидСправочника;
		СтрокаЭлемента.Пометка = Истина;
	КонецЦикла;
	Возврат СтрокаСправочника.Количество;
КонецФункции

// Процедура - выполняет непосредственное удаление элементов из универсального хранилища.
//
Процедура ВыполнитьУдаление() Экспорт
	
	Сообщение = "";
	УбратьНеПомеченные();
	
	НачатьТранзакцию();
	
	НайтиСсылки();
	ОпределитьВозможностьУдаления();
	
	ТипыКУдалению = Новый Массив();
	ВидыКОповещению.Очистить();
	
	ВсегоУдалено = 0;
	ВсегоНеУдалено = 0;
	
	Для каждого СтрокаТипа Из Объекты.Строки Цикл
		СтрокиКУдалению = СтрокаТипа.Строки.НайтиСтроки(Новый Структура("Пометка", Истина));
		Удалено = СтрокиКУдалению.Количество();
		Неудалено = СтрокаТипа.Строки.Количество() - Удалено;
		ВсегоУдалено = ВсегоУдалено + Удалено;
		ВсегоНеУдалено = ВсегоНеУдалено + Неудалено;
		Сообщение = Сообщение+"Справочник """+СтрокаТипа.ВидСправочника.Наименование+""" удалено: "+Удалено+", не удалено: "+Неудалено+Символы.ПС;
		
		Если СтрокиКУдалению.Количество()=0 Тогда
			Продолжить;
		КонецЕсли;
		
		ВидыКОповещению.Добавить().ВидСправочника = СтрокаТипа.ВидСправочника;
		Метаданные_ = нсиУниверсальноеХранилище.ПолучитьМетаданные(СтрокаТипа.ВидСправочника);
		
		Для каждого СтрокаОбъекта Из СтрокиКУдалению Цикл
			СпрОбъект = СтрокаОбъекта.Элемент.ПолучитьОбъект();
			Если СпрОбъект<>Неопределено Тогда 
				СпрОбъект.Удалить();
			КонецЕсли;
			СтрокаТипа.Строки.Удалить(СтрокаОбъекта);
		КонецЦикла;
		
		СтрокаТипа.Количество = СтрокаТипа.Строки.Количество();
		СтрокаТипа.Текст = Строка(СтрокаТипа.ВидСправочника)+" ("+Строка(СтрокаТипа.Количество)+")";
		Если СтрокаТипа.Количество=0 Тогда
			ТипыКУдалению.Добавить(СтрокаТипа);
		КонецЕсли;
		
	КонецЦикла;
	
	ЗафиксироватьТранзакцию();
	
	Для каждого СтрокаТипа Из ТипыКУдалению Цикл
		Объекты.Строки.Удалить(СтрокаТипа);
	КонецЦикла;
	
	Сообщение = Сообщение+"Всего удалено: "+ВсегоУдалено+", не удалено: "+ВсегоНеУдалено+Символы.ПС;
	
КонецПроцедуры

Процедура УбратьНеПомеченные()
	УдалитьТипы = Новый Массив();
	Для каждого СтрокаТипа Из Объекты.Строки Цикл
		Для каждого СтрокаТЧ Из СтрокаТипа.Строки.НайтиСтроки(Новый Структура("Пометка", Ложь)) Цикл
			СтрокаТипа.Строки.Удалить(СтрокаТЧ);
		КонецЦикла;
		СтрокаТипа.Количество = СтрокаТипа.Строки.Количество();
		Если СтрокаТипа.Количество=0 Тогда
			УдалитьТипы.Добавить(СтрокаТипа);
		КонецЕсли;
	КонецЦикла;
	Для каждого СтрокаТипа из УдалитьТипы Цикл
		Объекты.Строки.Удалить(СтрокаТипа);
	КонецЦикла;
КонецПроцедуры

Процедура НайтиСсылки()
	Зависимые = Новый ТаблицаЗначений();
	Зависимые.Колонки.Добавить("Элемент");
	Зависимые.Колонки.Добавить("Текст");
	Зависимые.Колонки.Добавить("ЗависимыйВид");
	Зависимые.Колонки.Добавить("ЗависимыйЭлемент");
	
	Зависимые.Индексы.Добавить("Элемент,ЗависимыйВид,ЗависимыйЭлемент,Текст");
	
	МассивСсылок = Новый Массив;
	Для Каждого СтрокаТипа Из Объекты.Строки Цикл
		Для Каждого СтрокаЭлемента Из СтрокаТипа.Строки Цикл;
			МассивСсылок.Добавить(СтрокаЭлемента.Элемент);
		КонецЦикла;
	КонецЦикла;
	
	НайденныеСсылки = НайтиПоСсылкам(МассивСсылок);
	
	Для Каждого Строка Из НайденныеСсылки Цикл
		Если Строка.Метаданные = Метаданные.РегистрыСведений.нсиХранилищеСсылка Тогда 
			НС = Зависимые.Добавить();
			НС.Элемент = Строка.Ссылка;
			Если Строка.Данные.ВидСправочника.ВидСправочника = Перечисления.нсиВидыСправочников.ТабличнаяЧасть Тогда 
				МЗ = РегистрыСведений.нсиХранилищеСтрока.СоздатьМенеджерЗаписи();
				МЗ.Элемент = Строка.Данные.Элемент;
				МЗ.ВидСправочника = Строка.Данные.ВидСправочника;
				МЗ.Реквизит = Справочники.нсиПредопределенныеРеквизиты.Код;
				МЗ.Прочитать();
				Если МЗ.Выбран() Тогда 
					НС.ЗависимыйЭлемент = МЗ.ВладелецСсылка;
					Если ТипЗнч(НС.ЗависимыйЭлемент) = Тип("СправочникСсылка.нсиУниверсальныйФункциональныйСправочник")
						ИЛИ ТипЗнч(НС.ЗависимыйЭлемент) = Тип("СправочникСсылка.нсиУниверсальныйКлассификатор") Тогда 
						
						НС.ЗависимыйВид = НС.ЗависимыйЭлемент.Владелец;
					Иначе
						НС.ЗависимыйВид = МЗ.ВладелецСсылка.Метаданные().ПолноеИмя();
					КонецЕсли;
				КонецЕсли;
			Иначе
				ИмяСправочника = нсиУниверсальноеХранилищеПовтИсп.ПолучитьИмяСправочникаХранилища(Строка.Данные.ВидСправочника);
				НС.ЗависимыйВид = Строка.Данные.ВидСправочника;
				НС.ЗависимыйЭлемент = Справочники[ИмяСправочника].ПолучитьССылку(Строка.Данные.Элемент);
			КонецЕсли;
			НС.Текст = Строка(НС.ЗависимыйЭлемент)+" ("+Строка(НС.ЗависимыйВид)+")";
		ИначеЕсли Строка.Метаданные = Метаданные.Справочники.нсиУниверсальныйФункциональныйСправочник
			ИЛИ Строка.Метаданные = Метаданные.Справочники.нсиУниверсальныйКлассификатор Тогда 
			
			НС = Зависимые.Добавить();
			НС.Элемент = Строка.Ссылка;
			Если ТипЗнч(Строка.Данные) = Тип("СправочникСсылка.нсиУниверсальныйФункциональныйСправочник")
				ИЛИ ТипЗнч(Строка.Данные) = Тип("СправочникСсылка.нсиУниверсальныйКлассификатор") Тогда 
				
				НС.ЗависимыйВид = Строка.Данные.Владелец;
			Иначе
				НС.ЗависимыйВид = Строка.Метаданные.ПолноеИмя();
			КонецЕсли;
			НС.ЗависимыйЭлемент = Строка.Данные;
			НС.Текст = Строка(НС.ЗависимыйЭлемент)+" ("+Строка(НС.ЗависимыйВид)+")";
		ИначеЕсли Метаданные.РегистрыСведений.Содержит(Строка.Метаданные) Тогда 
			Если НЕ Строка.Метаданные.Имя = "нсиСтатусыОбработкиСправочников"
				И НЕ Строка.Метаданные.Имя = "ВерсииОбъектов" Тогда 
				
				НС = Зависимые.Добавить();
				НС.Элемент = Строка.Ссылка;
				НС.ЗависимыйВид = Строка.Метаданные.ПолноеИмя();
				НС.ЗависимыйЭлемент = ЗначениеВСтрокуВнутр(Строка.Данные);
				НС.Текст = "Запись регистра сведений ("+НС.ЗависимыйВид+")";
			КонецЕсли;
		Иначе
			НС = Зависимые.Добавить();
			НС.Элемент = Строка.Ссылка;
			НС.ЗависимыйВид = Строка.Метаданные.ПолноеИмя();
			НС.ЗависимыйЭлемент = Строка.Данные;
			НС.Текст = Строка(НС.ЗависимыйЭлемент)+" ("+Строка(НС.ЗависимыйВид)+")";
		КонецЕсли;
	КонецЦикла;

	Зависимые.Свернуть("Элемент,ЗависимыйВид,ЗависимыйЭлемент,Текст");
	
	Для Каждого СтрокаТипа Из Объекты.Строки Цикл
		Для каждого СтрокаЭлемента Из СтрокаТипа.Строки Цикл
			Для каждого Найденная Из Зависимые.НайтиСтроки(Новый Структура("Элемент", СтрокаЭлемента.Элемент)) Цикл
				СтрокаЗависимости = СтрокаЭлемента.Строки.Добавить();
				СтрокаЗависимости.ВидСправочника = Найденная.ЗависимыйВид;
				СтрокаЗависимости.Элемент = Найденная.ЗависимыйЭлемент;
				СтрокаЗависимости.Текст =  Найденная.Текст;
			КонецЦикла;
		КонецЦикла;
	КонецЦикла;
		
КонецПроцедуры

// Функция - возвращает строковое представление для текста запроса.
//
Функция ВыражениеПредставления(ПолеПредставления) Экспорт
	Возврат "
	|	ВЫБОР КОГДА ВТПрава.Просмотр = Истина
	|		ТОГДА ВЫБОРК КОГДА "+ПолеПредставления+" = """" ТОГДА ""<>"" ИНАЧЕ "+ПолеПредставления+" КОНЕЦ
	|		ИНАЧЕ ""<Недостаточно прав для просмотра>""
	|	КОНЕЦ
	|";
КонецФункции

Процедура ОпределитьВозможностьУдаления()
	Обработанные = Новый Соответствие();
	Цепь = Новый Соответствие();
	Для каждого СтрокаТипа Из Объекты.Строки Цикл
		Для каждого СтрокаОбъекта Из СтрокаТипа.Строки Цикл
			УдалениеВозможно(СтрокаОбъекта, Цепь, Обработанные);
		КонецЦикла;
	КонецЦикла;
КонецПроцедуры

Функция УдалениеВозможно(ИсходнаяСтрокаОбъекта, Цепь, Обработанные)
	Если Обработанные[ИсходнаяСтрокаОбъекта]<>Неопределено Тогда
		Возврат Истина;
	КонецЕсли;
	
	Цепь.Вставить(ИсходнаяСтрокаОбъекта, 0);
	
	Результат = Истина;
	Для каждого СтрокаЗависимость Из ИсходнаяСтрокаОбъекта.Строки Цикл
	
		СтрокаТипа = Объекты.Строки.Найти(СтрокаЗависимость.ВидСправочника, "ВидСправочника");
		Если СтрокаТипа=Неопределено Тогда
			Результат = Ложь;
			Прервать;
		КонецЕсли;
		СтрокаОбъекта = СтрокаТипа.Строки.Найти(СтрокаЗависимость.Элемент, "Элемент");
		Если СтрокаОбъекта=Неопределено Тогда
			Результат = Ложь;
			Прервать;
		КонецЕсли;
		
		Если Цепь[СтрокаОбъекта]<>Неопределено Тогда
			Результат = Неопределено;
			Продолжить;
		КонецЕсли;
		
		Если УдалениеВозможно(СтрокаОбъекта, Цепь, Обработанные) Тогда
			Если не СтрокаОбъекта.Пометка Тогда
				Результат = Ложь;
				Прервать;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	Цепь.Удалить(ИсходнаяСтрокаОбъекта);
	
	Если Результат=Неопределено Тогда
		Возврат Ложь;
	Иначе
		ИсходнаяСтрокаОбъекта.Пометка = Результат;
		Обработанные.Вставить(ИсходнаяСтрокаОбъекта, 0);
		Возврат Истина;
	КонецЕсли;
КонецФункции

#КонецОбласти
