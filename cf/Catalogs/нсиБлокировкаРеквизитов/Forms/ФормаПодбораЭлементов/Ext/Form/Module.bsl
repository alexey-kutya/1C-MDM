﻿#Область ОбработчикиСобытийФормы

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Если ТипЗнч(Параметры.ИмяСправочника) = Тип("Строка") Тогда 
		Форма = ПолучитьФорму("Справочник."+Параметры.ИмяСправочника+".ФормаОбъекта");
	Иначе
		ИмяСправочника = нсиУниверсальноеХранилищеПовтИсп.ПолучитьИмяСправочникаХранилища(Параметры.ИмяСправочника);
		Форма = ПолучитьФорму(
			"Справочник."+ИмяСправочника+".ФормаОбъекта",
			новый Структура("ЗначенияЗаполнения",
				новый Структура("Владелец",Параметры.ИмяСправочника)
			)
		);
	КонецЕсли; 
	ЗаполнитьДеревоЭлементов(Форма,ДеревоЭлементов);
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОК(Команда)
	СЗ = новый СписокЗначений;
	ЭлементыДерева = ДеревоЭлементов.ПолучитьЭлементы();
	ЗаполнитьСписокЭлементов(СЗ,ДеревоЭлементов);
	Закрыть(СЗ);
КонецПроцедуры

&НаКлиенте
Процедура Отмена(Команда)
	Закрыть();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ЗаполнитьДеревоЭлементов(Элемент,ЭлементДерева)
	ЭлементыДерева = ЭлементДерева.ПолучитьЭлементы();
	Попытка
		Для Каждого Э Из Элемент.ПодчиненныеЭлементы Цикл
			НС = ЭлементыДерева.Добавить();
			НС.ИмяЭлемента = Э.Имя;
			НС.ТипЭлемента = ТипЗнч(Э);
			ЗаполнитьДеревоЭлементов(Э,НС);
		КонецЦикла;
	Исключение
	КонецПопытки;
КонецПроцедуры

&НаКлиенте
Процедура ДеревоЭлементовПометкаПриИзменении(Элемент)
	ТС = Элементы.ДеревоЭлементов.ТекущаяСтрока;
	ЭлементДерева = ДеревоЭлементов.НайтиПоИдентификатору(ТС);
	Если ЭлементДерева.Пометка Тогда 
		УстановитьПометкуРодительскихЭлементов(ЭлементДерева,Истина);
	Иначе
		УстановитьПометкуПодчиненныхЭлементов(ЭлементДерева,Ложь);
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ЗаполнитьСписокЭлементов(СЗ,ЭлементДерева)
	ЭлементыДерева = ЭлементДерева.ПолучитьЭлементы();
	Для Каждого Э Из ЭлементыДерева Цикл 
		Если Э.Пометка Тогда 
			СЗ.Добавить(Э.ИмяЭлемента);
		КонецЕсли;
		ЗаполнитьСписокЭлементов(СЗ,Э);
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура УстановитьПометкуРодительскихЭлементов(ЭлементДерева,Пометка)
	Родитель = ЭлементДерева.ПолучитьРодителя();
	Пока Родитель <> Неопределено Цикл 
		Родитель.Пометка = Пометка;
		Родитель = Родитель.ПолучитьРодителя();
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура УстановитьПометкуПодчиненныхЭлементов(ЭлементДерева,Пометка)
	ЭлементыДерева = ЭлементДерева.ПолучитьЭлементы();
	Для Каждого Э Из ЭлементыДерева Цикл
		Э.Пометка = Пометка;
		УстановитьПометкуПодчиненныхЭлементов(Э,Пометка)
	КонецЦикла;
КонецПроцедуры

#КонецОбласти