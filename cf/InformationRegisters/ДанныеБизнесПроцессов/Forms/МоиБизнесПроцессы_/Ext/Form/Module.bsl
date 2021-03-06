﻿
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("АвтоТест") Тогда // Возврат при получении формы для анализа.
		Возврат;
	КонецЕсли;
	
	Если НЕ ПолучитьФункциональнуюОпцию("ИспользоватьБизнесПроцессыИЗадачи") Тогда 
		Отказ = Истина;
		Возврат;
	КонецЕсли;
	
	УстановитьОтбор(Новый Структура("ПоказыватьЗавершенные", ПоказыватьЗавершенные));
	
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
		СписокНоменклатура, "Автор", ПользователиКлиентСервер.ТекущийПользователь());
	БизнесПроцессыИЗадачиСервер.УстановитьОформлениеБизнесПроцессов(СписокНоменклатура.УсловноеОформление);
	
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
		СписокКонтрагенты, "Автор", ПользователиКлиентСервер.ТекущийПользователь());
	БизнесПроцессыИЗадачиСервер.УстановитьОформлениеБизнесПроцессов(СписокНоменклатура.УсловноеОформление);
	
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
		СписокКонтрагентыСтатусы, "Автор", ПользователиКлиентСервер.ТекущийПользователь());
	БизнесПроцессыИЗадачиСервер.УстановитьОформлениеБизнесПроцессов(СписокНоменклатура.УсловноеОформление);
	
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
		СписокНоменклатураСтатусы, "Автор", ПользователиКлиентСервер.ТекущийПользователь());
	БизнесПроцессыИЗадачиСервер.УстановитьОформлениеБизнесПроцессов(СписокНоменклатура.УсловноеОформление);
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	Если ИмяСобытия = "Запись_ЗадачаИсполнителя" Тогда
		Элементы.Список.Обновить();
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ПриЗагрузкеДанныхИзНастроекНаСервере(Настройки)
	
	УстановитьОтбор(Настройки);
		
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ПоказыватьЗавершенныеПриИзменении(Элемент)
	
	УстановитьОтбор(Новый Структура("ПоказыватьЗавершенные", ПоказыватьЗавершенные));
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыСписок

&НаКлиенте
Процедура СписокВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	Если Элементы.Список.ТекущиеДанные <> Неопределено Тогда
		ПоказатьЗначение(,Элементы.Список.ТекущиеДанные.БизнесПроцесс);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СписокПередНачаломИзменения(Элемент, Отказ)
	
	Если Элемент.ТекущиеДанные <> Неопределено Тогда
		ПоказатьЗначение(,Элемент.ТекущиеДанные.БизнесПроцесс);
		Отказ = Истина;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ПометкаУдаления(Команда)
	БизнесПроцессыИЗадачиКлиент.СписокБизнесПроцессовПометкаУдаления(Элементы.Список);
КонецПроцедуры

&НаКлиенте
Процедура КартаМаршрута(Команда)
	Если Элементы.Список.ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ОткрытьФорму("Обработка.КартаМаршрутаБизнесПроцесса.Форма", 
		Новый Структура("БизнесПроцесс", Элементы.Список.ТекущиеДанные.БизнесПроцесс));
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура УстановитьОтбор(ПараметрыОтбора)
	
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
		СписокНоменклатура, "Завершен", Ложь,,, Не ПараметрыОтбора["ПоказыватьЗавершенные"]);
		
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
		СписокКонтрагенты, "Завершен", Ложь,,, Не ПараметрыОтбора["ПоказыватьЗавершенные"]);
		
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
		СписокНоменклатураСтатусы, "Завершен", Ложь,,, Не ПараметрыОтбора["ПоказыватьЗавершенные"]);
	
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
		СписокКонтрагентыСтатусы, "Завершен", Ложь,,, Не ПараметрыОтбора["ПоказыватьЗавершенные"]);
		
КонецПроцедуры

&НаКлиенте
Процедура СписокНоменклатураВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	Если Элементы.СписокНоменклатура.ТекущиеДанные <> Неопределено Тогда
		ПоказатьЗначение(,Элементы.СписокНоменклатура.ТекущиеДанные.БизнесПроцесс);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура СписокКонтрагентыВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	Если Элементы.СписокКонтрагенты.ТекущиеДанные <> Неопределено Тогда
		ПоказатьЗначение(,Элементы.СписокКонтрагенты.ТекущиеДанные.БизнесПроцесс);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура СписокНоменклатураСтатусыВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	Если Элементы.СписокНоменклатураСтатусы.ТекущиеДанные <> Неопределено Тогда
		ПоказатьЗначение(,Элементы.СписокНоменклатураСтатусы.ТекущиеДанные.БизнесПроцесс);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура СписокКонтрагентыСтатусыВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	Если Элементы.СписокКонтрагентыСтатусы.ТекущиеДанные <> Неопределено Тогда
		ПоказатьЗначение(,Элементы.СписокКонтрагентыСтатусы.ТекущиеДанные.БизнесПроцесс);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура СписокНоменклатураПередНачаломИзменения(Элемент, Отказ)
	
	Если Элемент.ТекущиеДанные <> Неопределено Тогда
		ПоказатьЗначение(,Элемент.ТекущиеДанные.БизнесПроцесс);
		Отказ = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СписокКонтрагентыПередНачаломИзменения(Элемент, Отказ)
	
	Если Элемент.ТекущиеДанные <> Неопределено Тогда
		ПоказатьЗначение(,Элемент.ТекущиеДанные.БизнесПроцесс);
		Отказ = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СписокНоменклатураСтатусыПередНачаломИзменения(Элемент, Отказ)
	
	Если Элемент.ТекущиеДанные <> Неопределено Тогда
		ПоказатьЗначение(,Элемент.ТекущиеДанные.БизнесПроцесс);
		Отказ = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СписокКонтрагентыСтатусыПередНачаломИзменения(Элемент, Отказ)
	
	Если Элемент.ТекущиеДанные <> Неопределено Тогда
		ПоказатьЗначение(,Элемент.ТекущиеДанные.БизнесПроцесс);
		Отказ = Истина;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти
