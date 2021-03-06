﻿
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("АвтоТест") Тогда // Возврат при получении формы для анализа.
		Возврат;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Объект.Ссылка)
	   И Параметры.ЗначенияЗаполнения.Свойство("Наименование") Тогда
		
		Объект.Наименование = Параметры.ЗначенияЗаполнения.Наименование;
	КонецЕсли;
	
	Если НЕ Параметры.СкрытьВладельца Тогда
		Элементы.Владелец.Видимость = Истина;
	КонецЕсли;
	
	Если ТипЗнч(Параметры.ПоказатьВес) = Тип("Булево") Тогда
		ПоказатьВес = Параметры.ПоказатьВес;
	ИначеЕсли ТипЗнч(Объект.Владелец) = Тип("ПланВидовХарактеристикСсылка.ДополнительныеРеквизитыИСведения") тогда
		ПоказатьВес = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Объект.Владелец, "ДополнительныеЗначенияСВесом");
	Иначе 
		ПоказатьВес = Ложь;
	КонецЕсли;
	
	Если ПоказатьВес = Истина Тогда
		Элементы.Вес.Видимость = Истина;
		СтандартныеПодсистемыСервер.УстановитьКлючНазначенияФормы(ЭтотОбъект, "ЗначенияСВесом");
	Иначе
		Элементы.Вес.Видимость = Ложь;
		Объект.Вес = 0;
		СтандартныеПодсистемыСервер.УстановитьКлючНазначенияФормы(ЭтотОбъект, "ЗначенияБезВеса");
	КонецЕсли;
	
	УстановитьЗаголовок();
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия = "Изменение_ЗначениеХарактеризуетсяВесовымКоэффициентом"
	   И Источник = Объект.Владелец Тогда
		
		Если Параметр = Истина Тогда
			Элементы.Вес.Видимость = Истина;
		Иначе
			Элементы.Вес.Видимость = Ложь;
			Объект.Вес = 0;
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	
	УстановитьЗаголовок();
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	
	Оповестить("Запись_ЗначенияСвойствОбъектов",
		Новый Структура("Ссылка", Объект.Ссылка), Объект.Ссылка);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура УстановитьЗаголовок()
	
	Если ТипЗнч(Объект.Владелец) = Тип("ПланВидовХарактеристикСсылка.ДополнительныеРеквизитыИСведения") тогда
		
		ЗначенияРеквизитов = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(
		Объект.Владелец, "Заголовок, ЗаголовокФормыЗначения");
		
		ИмяСвойства = СокрЛП(ЗначенияРеквизитов.ЗаголовокФормыЗначения);
		
		Если НЕ ПустаяСтрока(ИмяСвойства) Тогда
			Если ЗначениеЗаполнено(Объект.Ссылка) Тогда
				Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = '%1 (%2)'"),
				Объект.Наименование,
				ИмяСвойства);
			Иначе
				Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = '%1 (Создание)'"), ИмяСвойства);
			КонецЕсли;
		Иначе
			ИмяСвойства = Строка(ЗначенияРеквизитов.Заголовок);
			
			Если ЗначениеЗаполнено(Объект.Ссылка) Тогда
				Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = '%1 (Значение свойства %2)'"),
				Объект.Наименование,
				ИмяСвойства);
			Иначе
				Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Значение свойства %1 (Создание)'"), ИмяСвойства);
			КонецЕсли;
		КонецЕсли;
		
	ИначеЕсли ЗначениеЗаполнено(Объект.Владелец) Тогда
		ЗначенияРеквизитов = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Объект.Владелец, "Наименование");
		
		ИмяСвойства = Строка(ЗначенияРеквизитов.Наименование);
		Если ЗначениеЗаполнено(Объект.Ссылка) тогда
			Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = '%1 (Значение свойства %2)'"),
			Объект.Наименование,
			ИмяСвойства);
		Иначе 
			Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Значение свойства %1 (Создание)'"), ИмяСвойства);
		КонецЕсли;
	Иначе
		Заголовок = НСтр("ru = 'Значение свойства (Создание)'");
	КонецЕсли;

КонецПроцедуры

#КонецОбласти
