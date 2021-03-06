﻿Функция НайтиПоLocalID(ИмяСправочника, ID) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ИмяСправочника.LocalID
		|ИЗ
		|	Справочник.ИмяСправочника КАК ИмяСправочника
		|ГДЕ
		|	ИмяСправочника.LocalID ПОДОБНО &LocalID";
	
	Запрос.Текст = СтрЗаменить(Запрос.Текст, "ИмяСправочника", ИмяСправочника);
	
	Запрос.УстановитьПараметр("LocalID", ID+"%");
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Список = Новый СписокЗначений;
	
	Список.ЗагрузитьЗначения(РезультатЗапроса.Выгрузить().ВыгрузитьКолонку("LocalID"));
	
	Возврат Список;

КонецФункции // НайтиПоLocalIDНаСервере()

Функция СвязьМеждуЭлементамиСуществует(ИмяРегистраСоответствия, ИмяСправочникаLocal, ИмяСправочникаGlobal, LocalID, ID, ТекстОшибки = "", Отказ = Ложь, ТекущаяСсылка = Неопределено) Экспорт
	
	СсылкаLocal = ЭлементСправочникаНайтиПоID(ИмяСправочникаLocal, LocalID);
	СсылкаGlobal = ЭлементСправочникаНайтиПоID(ИмяСправочникаGlobal, ID, "ID", ТекущаяСсылка);
	
	Если ТипЗнч(СсылкаLocal) = Тип("Массив") Тогда
		ТекстОшибки = НСтр("ru = 'Существует более чем один элемент с таким локальным идентификатором.'; en = 'There is more than one item with such Local ID.'");
		Отказ = Истина;
		Возврат Отказ;
	КонецЕсли; 
	
	Если ТипЗнч(СсылкаGlobal) = Тип("Массив") Тогда
		ТекстОшибки = НСтр("ru = 'Существует более чем один элемент с таким глобальным идентификатором.'; en = 'There is more than one item with such Global ID.'");
		Отказ = Истина;
		Возврат Отказ;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(СсылкаLocal) 
		И ЗначениеЗаполнено(СсылкаGlobal) Тогда
		
		НаборЗаписей = РегистрыСведений.MappingGlobalAndLocalSKU.СоздатьНаборЗаписей();
		НаборЗаписей.Отбор.GlobalItem.Установить(СсылкаGlobal);
		НаборЗаписей.Отбор.LocalItem.Установить(СсылкаLocal);
		НаборЗаписей.Прочитать();
		
		Для каждого ЗаписьНабора Из НаборЗаписей Цикл
		
			ТекстОшибки = НСтр("ru = 'Данный локальный элемент уже имеет связь с указанным глобальным элементом.'; en = 'This Local item already has a link to the specified Global one.'");
			Отказ = Истина;
		
		КонецЦикла; 
		
	КонецЕсли;
	
	Возврат Отказ;
	
КонецФункции // СвязьМеждуЭлементамиСуществует(Отказ)()

Функция ЭлементСправочникаНайтиПоID(ИмяСправочника, ID, ИмяРеквизитаID = "LocalID", ТекущаяСсылка = Неопределено) Экспорт

	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ИмяСправочника.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.ИмяСправочника КАК ИмяСправочника
		|ГДЕ
		|	ИмяСправочника.ИмяРеквизитаID = &ID
		|	И ИмяСправочника.ЭтоМакет = ЛОЖЬ
		|	УсловиеСсылка";
		
	Если ТекущаяСсылка = Неопределено Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "УсловиеСсылка", "");
	ИначеЕсли ЗначениеЗаполнено(ТекущаяСсылка) Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "УсловиеСсылка", "И НЕ ИмяСправочника.Ссылка = &Ссылка");
		Запрос.УстановитьПараметр("Ссылка", ТекущаяСсылка);
	Иначе
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "УсловиеСсылка", "");
	КонецЕсли; 
	
	Запрос.Текст = СтрЗаменить(Запрос.Текст, "ИмяСправочника", ИмяСправочника);
	Запрос.Текст = СтрЗаменить(Запрос.Текст, "ИмяРеквизитаID", ИмяРеквизитаID);
	
	Запрос.УстановитьПараметр("ID", ID);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Если Выборка.Количество() > 1 Тогда
	    ЭлементСсылка = РезультатЗапроса.Выгрузить().ВыгрузитьКолонку("Ссылка");
	Иначе
		ЭлементСсылка = Справочники.GlobalSKU.ПустаяСсылка();
	
		Если Выборка.Следующий() Тогда
	
			ЭлементСсылка = Выборка.Ссылка;
		
		КонецЕсли; 
	КонецЕсли; 
	
	Возврат ЭлементСсылка;

КонецФункции // LocalIDЭлементСуществует(Объект.LocalID)()

Процедура УстановитьСоответствиеСЛокальным(СсылкаGlobal) Экспорт
	
	//УстановитьПривилегированныйРежим(Истина);
	//
	//Если ТипЗнч(СсылкаGlobal) = Тип("СправочникСсылка.GlobalSKU") Тогда
	//	ИмяРегистраСоответствия = "MappingGlobalAndLocalSKU";
	//	ИмяСправочникаLocal = "нсиМТР";
	//	ИмяСправочникаGlobal = "GlobalSKU";
	//ИначеЕсли ТипЗнч(СсылкаGlobal) = Тип("СправочникСсылка.GlobalPartners") Тогда
	//	ИмяРегистраСоответствия = "MappingGlobalAndLocalPartners";
	//	ИмяСправочникаLocal = "нсиКонтрагенты";
	//	ИмяСправочникаGlobal = "GlobalPartners";
	//Иначе
	//	Сообщить(НСтр("ru = 'Не удалось установить соответствие между глобальным и локальным элементом. '; en = 'Failed to match the global and local items.'"), СтатусСообщения.ОченьВажное);
	//	Сообщить(НСтр("ru = 'Для данного типа установление соответствия не предусмотрено!'; en = 'For this data type, there is no mapping!'"), СтатусСообщения.ОченьВажное);
	//	Возврат;
	//КонецЕсли; 
	//
	//Если ЗначениеЗаполнено(СсылкаGlobal.LocalID) Тогда
	//	ТекстОшибки = "";
	//	Если СвязьМеждуЭлементамиСуществует(ИмяРегистраСоответствия,ИмяСправочникаLocal,ИмяСправочникаGlobal,СсылкаGlobal.LocalID, СсылкаGlobal.ID, ТекстОшибки,,СсылкаGlobal) Тогда
	//		Сообщить(ТекстОшибки, СтатусСообщения.Важное);
	//		Возврат;
	//	КонецЕсли; 
	//	
	//Иначе
	//	Сообщить(НСтр("ru = 'Не удалось установить соответствие между глобальным и локальным элементом. '; en = 'Failed to match the global and local items.'"), СтатусСообщения.ОченьВажное);
	//	Сообщить(НСтр("ru = 'Не заполнен Локальный идентификатор!'; en = 'Local ID doesn't specify!'"), СтатусСообщения.ОченьВажное);
	//	Возврат;	
	//КонецЕсли; 
	//
	//СсылкаLocal = ЭлементСправочникаНайтиПоID(ИмяСправочникаLocal, СсылкаGlobal.LocalID);
	//
	//СсылкаGlobalНайденная = ЭлементСправочникаНайтиПоID(ИмяСправочникаGlobal, СсылкаGlobal.ID, "ID", СсылкаGlobal);
	//СсылкаGlobalВИзмерение = СсылкаGlobal;
	//
	//Если ТипЗнч(СсылкаGlobalНайденная) = Тип("Массив") Тогда
	//	Сообщить(НСтр("ru = 'Не удалось установить соответствие между глобальным и локальным элементом. '; en = 'Failed to match the global and local items.'"), СтатусСообщения.ОченьВажное);
	//	Сообщить(НСтр("ru = 'Существует несколько элементов с таким глобальным ID!'; en = 'There are several items with this Global ID!'"), СтатусСообщения.ОченьВажное);
	//	Возврат;
	//ИначеЕсли ЗначениеЗаполнено(СсылкаGlobalНайденная) Тогда 
	//	
	//	СсылкаGlobalВИзмерение = СсылкаGlobalНайденная;
	//	
	//КонецЕсли; 
	//
	//Если НЕ ЗначениеЗаполнено(СсылкаLocal) Тогда
	//	
	//	НовыйЭлемент = Справочники[ИмяСправочникаLocal].СоздатьЭлемент();
	//	НовыйЭлемент.LocalID = СсылкаGlobal.LocalID;
	//	НовыйЭлемент.Status = СсылкаGlobal.Status;
	//	НовыйЭлемент.СтранаОрганизации = СсылкаGlobal.СтранаОрганизации;
	//	НовыйЭлемент.СтранаОрганизацииРазделительДанных = СсылкаGlobal.СтранаОрганизации.Код;
	//	НовыйЭлемент.Наименование = СсылкаGlobal.Наименование;
	//	
	//	Попытка
	//	
	//		НовыйЭлемент.Записать();
	//		СсылкаLocal = НовыйЭлемент.Ссылка;
	//	
	//	Исключение
	//		Сообщить(НСтр("ru = 'Не удалось установить соответствие между глобальным и локальным элементом. '; en = 'Failed to match the global and local items.'"), СтатусСообщения.ОченьВажное);
	//		Сообщить(ОписаниеОшибки());
	//		Возврат;
	//	КонецПопытки;
	//КонецЕсли; 
	//
	//МенеджерЗаписи = РегистрыСведений[ИмяРегистраСоответствия].СоздатьМенеджерЗаписи();
	//МенеджерЗаписи.GlobalItem = СсылкаGlobalВИзмерение;
	//МенеджерЗаписи.LocalItem = СсылкаLocal;
	//МенеджерЗаписи.LocalID = СсылкаLocal.LocalID;
	//МенеджерЗаписи.Status = СсылкаLocal.Status;
	//МенеджерЗаписи.EntityCountry = СсылкаLocal.СтранаОрганизации;
	//
	//Попытка
	//	МенеджерЗаписи.Записать();
	//Исключение
	//	Сообщить(НСтр("ru = 'Не удалось установить соответствие между глобальным и локальным элементом. '; en = 'Failed to match the global and local items.'"), СтатусСообщения.ОченьВажное);
	//	Сообщить(ОписаниеОшибки());
	//КонецПопытки; 
	
КонецПроцедуры

Функция ДелатьЭлементОсновным(ИмяСправочника, ID, ИмяРеквизитаID, ТекущаяСсылка) Экспорт

	Ссылка = ЭлементСправочникаНайтиПоID(ИмяСправочника, ID, ИмяРеквизитаID, ТекущаяСсылка);
	
	Возврат НЕ ЗначениеЗаполнено(Ссылка);
	
КонецФункции // ДелатьЭлементОсновным()

Процедура ОбработкаПолученияФормы(Источник, ВидФормы, Параметры, ВыбраннаяФорма, ДополнительнаяИнформация, СтандартнаяОбработка) Экспорт
	
	//ГруппаУправленияНСИ = ПараметрыСеанса.ГруппаУправленияНСИ;
	//
	//Если ЗначениеЗаполнено(ПараметрыСеанса.ГруппаУправленияНСИ) Тогда
	//	
	//	ПараметрыОтбора = Новый Структура;
	//	ПараметрыОтбора.Вставить("ИмяОбъектаМетаданных", Строка(Источник));
	//	ПараметрыОтбора.Вставить("ВидФормы", ВидФормы);
	//	
	//	Строки = ГруппаУправленияНСИ.Формы.НайтиСтроки(ПараметрыОтбора);
	//	
	//	Если Строки.Количество() Тогда
	//		СтандартнаяОбработка = Ложь;
	//		ВыбраннаяФорма = Строки[0].ИмяФормы;
	//	КонецЕсли; 
	//	     
	//КонецЕсли; 
	
КонецПроцедуры

Процедура УстановитьСтатусВРегистреСоответствий(ИмяРегистраСоответствий, Ссылка, NewStatus)

	НаборЗаписей = РегистрыСведений[ИмяРегистраСоответствий].СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.LocalItem.Установить(Ссылка);
	НаборЗаписей.Прочитать();
	Для каждого Запись Из НаборЗаписей Цикл
		Запись.Status = NewStatus;
	КонецЦикла;
	НаборЗаписей.Записать();
	
КонецПроцедуры // УстановитьСтатусВРегистреСоответствий()

Процедура УстановитьНовыйСтатусНаСервере(Ссылка, NewStatus, ИмяРегистраСоответствий, Comments = "") Экспорт 

	РеквизитыСсылка = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Ссылка, "Status");
	
	Если NewStatus = РеквизитыСсылка.Status Тогда
		Сообщить(НСтр("ru = 'Новый статус не установлен! Новый статус должен отличаться от текущего.'; en = 'The status has NOT been changed, because it should be different from the current one!'"), СтатусСообщения.Внимание);
		Возврат;
	КонецЕсли; 
	
	УстановитьПривилегированныйРежим(Истина);
	
	Объект = Ссылка.ПолучитьОбъект();
	Объект.Status = NewStatus;
	Попытка
		Объект.Записать();
		
		СоздатьБизнесПроцессыУведомление(Ссылка, РеквизитыСсылка.Status, NewStatus, Comments);
		
		УстановитьСтатусВРегистреСоответствий(ИмяРегистраСоответствий, Ссылка, NewStatus);
		
		Сообщить(НСтр("ru = 'Новый статус успешно установлен.'; en = 'The status has been changed successfully.'"));
	Исключение
		Сообщить(НСтр("ru = 'Не удалось установить новый статус. Смотрите сообщение об ошибке.'; en = 'Failed to set a new status. See the error message.'"), СтатусСообщения.ОченьВажное);	
		Сообщить(ОписаниеОшибки(), СтатусСообщения.ОченьВажное);	
	КонецПопытки; 

КонецПроцедуры // УстановитьНовыйСтатусНаСервере()

Процедура СоздатьБизнесПроцессыУведомление(Ссылка, CurrentStatus, NewStatus, Comments)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ИсполнителиЗадач.Исполнитель
		|ИЗ
		|	РегистрСведений.ИсполнителиЗадач КАК ИсполнителиЗадач
		|ГДЕ
		|	ИсполнителиЗадач.РольИсполнителя = &РольИсполнителя";
	
	Запрос.УстановитьПараметр("РольИсполнителя", ПредопределенноеЗначение("Справочник.РолиИсполнителей.GlobalMasterDataManager"));
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		
		СоздатьБизнесПроцессУведомление(Ссылка, CurrentStatus, NewStatus, ВыборкаДетальныеЗаписи.Исполнитель, Comments);
		
	КонецЦикла;
	
КонецПроцедуры // СоздатьБизнесПроцессУведомление()

Процедура СоздатьБизнесПроцессУведомление(Ссылка, CurrentStatus, NewStatus, Исполнитель, Comments)

	БП = БизнесПроцессы.Задание.СоздатьБизнесПроцесс();
	БП.Дата = ТекущаяДата();
	БП.Автор = Пользователи.АвторизованныйПользователь();
	БП.Важность = Перечисления.ВариантыВажностиЗадачи.Обычная;
	БП.Выполнено = Ложь;
	БП.Исполнитель = Исполнитель;
	
	Наименование = НСтр("ru = 'Status changing %1 to %2'; en = 'Status changing %1 to %2'", "en");
	Наименование = СтрЗаменить(Наименование,"%1",Ссылка.LocalID);
	Наименование = СтрЗаменить(Наименование,"%2",NewStatus);
	
	БП.Наименование = Наименование;
	БП.НаПроверке = Ложь;
	БП.Подтверждено = Ложь;
	БП.Предмет = Ссылка;
	
	ОписаниеЗадания = НСтр("ru = 'The status has been changed from ""%1"" to ""%2""'; en = 'The status has been changed from ""%1"" to ""%2""'", "en");
	ОписаниеЗадания = СтрЗаменить(ОписаниеЗадания,"%1",CurrentStatus);
	ОписаниеЗадания = СтрЗаменить(ОписаниеЗадания,"%2",NewStatus);
	
	Если ЗначениеЗаполнено(Comments) Тогда
		Причина = НСтр("ru = 'Причина:'; en = 'The reason:'");
		ОписаниеЗадания = ОписаниеЗадания+Символы.ПС+Символы.ПС+Причина+Символы.ПС+Comments;
	КонецЕсли; 
	
	БП.ОписаниеЗадания = ОписаниеЗадания;
	БП.Состояние = Перечисления.СостоянияБизнесПроцессов.Активен;
	//		БП.АвторСтрокой = ПользовательОтветственный.Наименование;
	БП.ВнешнееЗадание = Ложь;
	БП.ит_Назначение = ПредопределенноеЗначение("Перечисление.ВидыНазначенийБизнесПроцессов.Уведомление");
	//		БП.СодержаниеПредмета = СодержаниеПредмета;
	БП.Записать();
	БП.Старт();

КонецПроцедуры // ()

Функция ПолучитьРеквизитНаСервере(Ссылка, ИмяРеквизита) Экспорт 

	Возврат ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Ссылка, ИмяРеквизита);	

КонецФункции // ПолучитьРеквизитНаСервере()

Функция ЗначенияРеквизитовОбъектаНаСервере(Ссылка, ИменаРеквизитов) Экспорт 

	Возврат ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Ссылка, ИменаРеквизитов);	

КонецФункции // ПолучитьРеквизитНаСервере()