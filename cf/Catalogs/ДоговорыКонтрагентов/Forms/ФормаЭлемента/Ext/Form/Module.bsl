﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	//фыв ++ заполняем владельца, если создаем из формы контрагента
	ПараметрыЗаполнения=Параметры.ЗначенияЗаполнения;
	Если ПараметрыЗаполнения.Свойство("Владелец") И ЗначениеЗаполнено(ПараметрыЗаполнения.Владелец) Тогда
		Объект.Владелец=ПараметрыЗаполнения.Владелец;
	КонецЕсли;  //--
	
	//Кутья АА ITRR
	Если Параметры.Ключ.Пустая() Тогда
		Объект.ВалютаВзаиморасчетов = ВалютаРегламентированногоУчета();
		Объект.Наименование = "Основной договор";
		Объект.ВедениеВзаиморасчетов = Перечисления.ВедениеВзаиморасчетовПоДоговорам.ПоДоговоруВЦелом;
		Объект.ПолнаяСинхронизацияMDM = Истина;
	КонецЕсли; 
	
	MDMСервер.ЗаполнитьУчастниковОбмена(ЭтаФорма);
	MDMСервер.УстановитьУсловноеОформление(ЭтаФорма);
	MDMСервер.ДоступностьУчастниковОбмена(ЭтаФорма);
	
	GUID_MDM = Объект.Ссылка.УникальныйИдентификатор();
	
	ЭтоНовый = Параметры.Ключ.Пустая();
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ВалютаРегламентированногоУчета()

	Возврат Константы.ВалютаРегламентированногоУчета.Получить();

КонецФункции // ВалютаРегламентированногоУчета()

&НаКлиенте
Процедура ВидДоговораПриИзменении(Элемент)
	УстановитьДоступностьПоВидуДоговора();
	Если Объект.ВидДоговора.Пустая() ИЛИ Объект.ВидДоговора = ПредопределенноеЗначение("Перечисление.ВидыДоговоровКонтрагентов.Прочее") Тогда
		Объект.ВидУсловийДоговора                = ПредопределенноеЗначение("Перечисление.ВидыУсловийДоговоровВзаиморасчетов.БезДополнительныхУсловий");
		Объект.ВедениеВзаиморасчетов                    = ПредопределенноеЗначение("Перечисление.ВедениеВзаиморасчетовПоДоговорам.ПоДоговоруВЦелом");
		Объект.ВестиПоДокументамРасчетовСКонтрагентом   = Ложь;
	КонецЕсли;
	
	//Зачистка флага "Расчеты в условных единицах" для всех видов договоров кроме договоров в поставщиком и с покупателем
	Если не (Объект.ВидДоговора = ПредопределенноеЗначение("Перечисление.ВидыДоговоровКонтрагентов.СПоставщиком") 
		ИЛИ Объект.ВидДоговора = ПредопределенноеЗначение("Перечисление.ВидыДоговоровКонтрагентов.СПокупателем")) Тогда
		Объект.РасчетыВУсловныхЕдиницах = Ложь;
	КонецЕсли;

	//Зачистка флага "Реализация на экспорт" для всех видов договоров кроме договора с покупателем
	Если Не Объект.ВидДоговора = ПредопределенноеЗначение("Перечисление.ВидыДоговоровКонтрагентов.СПокупателем") Тогда
		Объект.РеализацияНаЭкспорт = Ложь;
	КонецЕсли;
	
КонецПроцедуры


&НаКлиенте
Процедура ПриОткрытии(Отказ)
	УстановитьДоступностьПоВидуДоговора();
	
	ЗаполнитьСписокВыбораВидаДоговора();
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьДоступностьПоВидуДоговора()

	ВидДоговораПрочее = Объект.ВидДоговора = ПредопределенноеЗначение("Перечисление.ВидыДоговоровКонтрагентов.Прочее");
	ВидДоговораПустое = НЕ ЗначениеЗаполнено(Объект.ВидДоговора);
	ДоступностьЭлементов = НЕ ВидДоговораПрочее И НЕ ВидДоговораПустое;
	
	Элементы.ВедениеВзаиморасчетов.Доступность = ДоступностьЭлементов;
	Элементы.ВестиПоДокументамРасчетовСКонтрагентом.Доступность = ДоступностьЭлементов;
	Элементы.РасчетыВУсловныхЕдиницах.Доступность = ДоступностьЭлементов;
	Элементы.ВидУсловийДоговора.Доступность = ДоступностьЭлементов;

КонецПроцедуры // УстановитьВидимостьПоВидуДоговора()
 
&НаКлиенте
Процедура ЗаполнитьСписокВыбораВидаДоговора()

	Если НЕ ЗначениеЗаполнено(Объект.Владелец) Тогда
		УстановитьСписокПоляВыбора(Элементы.ВидДоговора, ПолучитьСписокВидовДоговоровВзаиморасчетовПрочее());
		ВидДоговора = ПредопределенноеЗначение("Перечисление.ВидыДоговоровКонтрагентов.ПустаяСсылка");
	Иначе
		РеквизитыКонтрагента = ЗначенияРеквизитовОбъектаНаСервере(Объект.Владелец, "Покупатель,Поставщик");
		Если РеквизитыКонтрагента.Покупатель И РеквизитыКонтрагента.Поставщик Тогда
			УстановитьСписокПоляВыбора(Элементы.ВидДоговора, ПолучитьСписокЭлементовПеречисления("ВидыДоговоровКонтрагентов"));
		ИначеЕсли РеквизитыКонтрагента.Покупатель Тогда
			УстановитьСписокПоляВыбора(Элементы.ВидДоговора, ПолучитьСписокВидовДоговоровВзаиморасчетовДляПокупателя());
		ИначеЕсли РеквизитыКонтрагента.Поставщик Тогда
			УстановитьСписокПоляВыбора(Элементы.ВидДоговора, ПолучитьСписокВидовДоговоровВзаиморасчетовДляПоставщика());
		Иначе
			УстановитьСписокПоляВыбора(Элементы.ВидДоговора, ПолучитьСписокВидовДоговоровВзаиморасчетовПрочее());
		КонецЕсли; 
	КонецЕсли;

КонецПроцедуры

&НаСервереБезКонтекста
Функция ЗначенияРеквизитовОбъектаНаСервере(Ссылка, ИменаРеквизитов)

	Возврат ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Ссылка, ИменаРеквизитов);

КонецФункции // ЗначенияРеквизитовОбъектаНаСервере()
 
&НаКлиенте
Процедура УстановитьСписокПоляВыбора(ПолеВыбора, Список) Экспорт
	
	ПрошлоеЗначение = Объект[ПолеВыбора.Имя];
	ПолеВыбора.СписокВыбора.ДоступныеЗначения = Список;
	ПолеВыбора.СписокВыбора.Очистить();
	ПолеВыбора.СписокВыбора.ЗагрузитьЗначения(Список.ВыгрузитьЗначения());
	Если ЗначениеЗаполнено(ПрошлоеЗначение) Тогда
		Если  Список.НайтиПоЗначению(ПрошлоеЗначение) <> Неопределено Тогда
			Если НЕ Объект[ПолеВыбора.Имя] = ПрошлоеЗначение Тогда
				Объект[ПолеВыбора.Имя] = ПрошлоеЗначение;
			КонецЕсли;
		Иначе
			Объект[ПолеВыбора.Имя] = Неопределено;
		КонецЕсли;
	КонецЕсли; 
	
КонецПроцедуры // УстановитьСписокПоляВыбора()

&НаСервереБезКонтекста
Функция ПолучитьСписокВидовДоговоровВзаиморасчетовПрочее() Экспорт

	СписокПеречисления = Новый СписокЗначений;
	
	СписокПеречисления.Добавить(Перечисления.ВидыДоговоровКонтрагентов.Прочее);
	
	Возврат СписокПеречисления;

КонецФункции // ПолучитьСписокВидовДоговоровВзаиморасчетовПрочее()
 
&НаСервереБезКонтекста
Функция ПолучитьСписокЭлементовПеречисления(ИмяПеречисления) Экспорт
	
	СписокЭлементовПеречисления = Новый СписокЗначений;
	
	Попытка
		КоллекцияЭлементовПеречисления = Перечисления[ИмяПеречисления];
	Исключение
		Возврат СписокЭлементовПеречисления;
	КонецПопытки;
	
	Для каждого ЭлементПеречисления Из КоллекцияЭлементовПеречисления Цикл
		СписокЭлементовПеречисления.Добавить(ЭлементПеречисления, Строка(ЭлементПеречисления));
	КонецЦикла;
	
	Возврат СписокЭлементовПеречисления;
	
КонецФункции // ПолучитьСписокЭлементовПеречисления()

&НаСервереБезКонтекста
Функция ПолучитьСписокВидовДоговоровВзаиморасчетовДляПокупателя() Экспорт

	СписокПеречисления = Новый СписокЗначений;
	
	СписокПеречисления.Добавить(Перечисления.ВидыДоговоровКонтрагентов.СПокупателем);
	СписокПеречисления.Добавить(Перечисления.ВидыДоговоровКонтрагентов.СКомиссионером);
	СписокПеречисления.Добавить(Перечисления.ВидыДоговоровКонтрагентов.Прочее);
	
	Возврат СписокПеречисления;

КонецФункции // ПолучитьСписокВидовДоговоровВзаиморасчетовДляПокупателя()

&НаСервереБезКонтекста
Функция ПолучитьСписокВидовДоговоровВзаиморасчетовДляПоставщика() Экспорт

	СписокПеречисления = Новый СписокЗначений;
	
	СписокПеречисления.Добавить(Перечисления.ВидыДоговоровКонтрагентов.СПоставщиком);
	СписокПеречисления.Добавить(Перечисления.ВидыДоговоровКонтрагентов.СКомитентом);
	СписокПеречисления.Добавить(Перечисления.ВидыДоговоровКонтрагентов.Прочее);
	
	Возврат СписокПеречисления;

КонецФункции // ПолучитьСписокВидовДоговоровВзаиморасчетовДляПоставщика()

&НаКлиенте
Процедура ВидДоговораНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ЗаполнитьСписокВыбораВидаДоговора();
КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	//КутьяАА ITRR
	Если НЕ Отказ И Модифицированность Тогда
		MDMСервер.ЗаписатьУчастниковОбмена(ЭтаФорма);
	КонецЕсли; 
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	//КутьяАА ITRR <<
	
	Если ЭтоНовый Тогда
		Отбор = Новый Структура;
		Отбор.Вставить("УзелОбмена", ПланыОбмена.Обмен_МДМ_УПП.ПолучитьУзелПоОрганизации(ТекущийОбъект.Организация));
		Отбор.Вставить("ОбменВладелец", Истина);
		Отбор.Вставить("Обмен", Ложь);
		
		СтрокиУчастников = УчастникиОбмена.НайтиСтроки(Отбор);
		Если СтрокиУчастников.Количество() Тогда
			СтрокиУчастников[0].Обмен = Истина;
			MDMСервер.ЗаписатьУчастниковОбмена(ЭтаФорма);
		КонецЕсли; 
	КонецЕсли; 
		
	MDMСервер.ДоступностьУчастниковОбмена(ЭтаФорма);
	
	УИ = Объект.Ссылка.УникальныйИдентификатор();
	Если НЕ GUID_MDM = УИ Тогда
		GUID_MDM = УИ;
	КонецЕсли; 
	//>>
КонецПроцедуры

&НаКлиенте
Процедура УчастникиОбменаПриИзменении(Элемент)
	//КутьяАА ITRR
	Если Элемент.ТекущийЭлемент.Имя = "УчастникиОбменаОбмен" Тогда
		Модифицированность = Истина;
	КонецЕсли; 
КонецПроцедуры

&НаКлиенте
Процедура ПерейтиПоСсылкеСЭД(Команда)
	
	MDMКлиент.ПерейтиПоСсылкеСЭД(Объект.НомерДокументаСЭД);
	
КонецПроцедуры

