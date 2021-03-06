﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	// @Комментарий: Скроем кнопку установки пометки на удаление, если прав недостаточно.
	ИмяБизнесПроцесса = "нсиУдалениеЭлементаСправочника";
	текКнопкаФормаУстановитьПометкуУдаления = Элементы.Найти("ФормаУстановитьПометкуУдаления");
	Если текКнопкаФормаУстановитьПометкуУдаления <> Неопределено Тогда
		текКнопкаФормаУстановитьПометкуУдаления.Видимость = нсиСравнениеДанныхСервер.ПроверитьПометкуНаУдалениеБизнесПроцессов(БизнесПроцессы[ИмяБизнесПроцесса].ПустаяСсылка());
	КонецЕсли;
	текКнопкаСписокКонтекстноеМенюУстановитьПометкуУдаления = Элементы.Найти("СписокКонтекстноеМенюУстановитьПометкуУдаления");
	Если текКнопкаСписокКонтекстноеМенюУстановитьПометкуУдаления <> Неопределено Тогда
		текКнопкаСписокКонтекстноеМенюУстановитьПометкуУдаления.Видимость = нсиСравнениеДанныхСервер.ПроверитьПометкуНаУдалениеБизнесПроцессов(БизнесПроцессы[ИмяБизнесПроцесса].ПустаяСсылка());
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура СписокПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа)
	
	Отказ = Истина;
	
	ПараметрыФормы = Новый Структура("Предмет", Параметры.Предмет);
	 ОткрытьФорму("БизнесПроцесс.нсиУдалениеЭлементаСправочника.ФормаОбъекта", 
		 Новый Структура("ЗначенияЗаполнения", ПараметрыФормы));
	
КонецПроцедуры

#КонецОбласти
