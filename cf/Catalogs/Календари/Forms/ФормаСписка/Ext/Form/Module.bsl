﻿
///////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ КОМАНД ФОРМЫ

&НаКлиенте
Процедура СоздатьПоШаблону(Команда)
	ОписаниеОповещения = Новый ОписаниеОповещения("ОбработкаЗакрытияНастройкиНовогоКалендаря",ЭтаФорма);
	ОткрытьФорму(
		"Справочник.Календари.Форма.НастройкаНовогоКалендаря",,ЭтаФорма,,,,
		ОписаниеОповещения,РежимОткрытияОкнаФормы.БлокироватьОкноВладельца
	);
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаЗакрытияНастройкиНовогоКалендаря(Результат, ДП) Экспорт
	Если Результат <> Неопределено Тогда 
		Родитель = Элементы.Список.ТекущийРодитель;
		Если Родитель<>Неопределено Тогда 
			Результат.Вставить("ЗначенияЗаполнения",новый Структура("Родитель",Родитель));
		КонецЕсли;
		ОткрытьФорму("Справочник.Календари.ФормаОбъекта",Результат,ЭтаФорма);
	КонецЕсли;
КонецПроцедуры


&НаКлиенте
Процедура СписокПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа)
	Если Группа Тогда 
		Возврат;
	КонецЕсли;
	
	Отказ = Истина;
	Если НЕ Копирование Тогда 
		ПараметрыНовогоКалендаря = Неопределено;
		
		ОписаниеОповещения = новый ОписаниеОповещения("ОбработкаОтветаСоздатьПоШаблону", ЭтаФорма,Родитель);
		Текст = НСтр("ru = 'Есть возможность создать календарь по шаблону, на основе данных производственного календаря.
			|Создать по шаблону?'");
		ПоказатьВопрос(ОписаниеОповещения, Текст, РежимДиалогаВопрос.ДаНет, , КодВозвратаДиалога.Нет);
		Возврат;
	Иначе
		Ссылка = Элементы.Список.ТекущаяСтрока;
		Если Ссылка<>Неопределено Тогда 
			ОткрытьФорму("Справочник.Календари.ФормаОбъекта",
				новый Структура("ЗначениеКопирования,ЗначенияЗаполнения",
					Ссылка,
					новый Структура("Родитель",Родитель)
				) ,
				ЭтаФорма);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОтветаСоздатьПоШаблону(Результат,Родитель) Экспорт
	Если Результат = КодВозвратаДиалога.Да Тогда
		
		ОписаниеОповещения = новый ОписаниеОповещения("ОбработкаЗакрытияНастройкиКалендаряПриВводеПоШаблону",ЭтаФорма,Родитель);
		ОткрытьФорму("Справочник.Календари.Форма.НастройкаНовогоКалендаря", , ЭтаФорма,,,,
			ОписаниеОповещения,
			РежимОткрытияОкнаФормы.БлокироватьОкноВладельца
		);
	Иначе
		ПараметрыНовогоКалендаря = Новый Структура;
		ПараметрыНовогоКалендаря.Вставить("ЗначенияЗаполнения",новый Структура("Родитель",Родитель));
		ОткрытьФорму("Справочник.Календари.ФормаОбъекта",ПараметрыНовогоКалендаря,ЭтаФорма);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаЗакрытияНастройкиКалендаряПриВводеПоШаблону(Результат,Родитель) Экспорт
	Если НЕ Результат = Неопределено Тогда 
		Результат.Вставить("ЗначенияЗаполнения",новый Структура("Родитель",Родитель));
		ОткрытьФорму("Справочник.Календари.ФормаОбъекта",Результат,ЭтаФорма);
	КонецЕсли;
КонецПроцедуры


