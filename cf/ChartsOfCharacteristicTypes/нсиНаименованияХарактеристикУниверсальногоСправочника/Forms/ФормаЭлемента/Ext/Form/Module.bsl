﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ЕдинственноеЧислоПредмета = СтрПолучитьСтроку(Объект.СклоненияПредмета, 1);
	МножественноеЧислоПредмета = СтрПолучитьСтроку(Объект.СклоненияПредмета, 2);
	
	УправлениеВидимостью();
	
	Если Параметры.Свойство("БезРедактирования") Тогда
		ТолькоПросмотр = Параметры.БезРедактирования;;		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗаписью(Отказ, ПараметрыЗаписи)
	
	Если Не Параметры.Ключ.Пустая()
		И Не ПараметрыЗаписи.Свойство("ВыполнитьРеструктуризациюСвязанныхДанных") тогда
		ТипЗначенияДоИзменения = нсиОбщегоНазначения.ПолучитьЗначениеРеквизита(Объект.Ссылка, "ТипЗначения");
		
		Если НЕ Объект.ТипЗначения = ТипЗначенияДоИзменения тогда
			КоличествоСвязанныхКлассов = 0;
			КоличествоСвязанныхЭлементов = 0;
			
			нсиРеструктуризацияТехническихХарактеристик.ПроверкаСвязанныхДанных(
				Объект.Ссылка, "нсиУниверсальныйФункциональныйСправочник", "нсиХарактеристикиУниверсальногоСправочника", 
				КоличествоСвязанныхКлассов, КоличествоСвязанныхЭлементов);
			
			Если КоличествоСвязанныхКлассов > 0 ИЛИ КоличествоСвязанныхЭлементов > 0 тогда
				
				ПоказатьВопрос(Новый ОписаниеОповещения("ПередЗаписьюЗавершение", ЭтотОбъект, ПараметрыЗаписи),
					нсиРеструктуризацияТехническихХарактеристик.СформироватьТекстВопросаРеструктуризацииДанных(
					КоличествоСвязанныхКлассов, КоличествоСвязанныхЭлементов), 
 					РежимДиалогаВопрос.ДаНет);		
					
				Отказ = Истина;
			КонецЕсли;	
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗаписьюЗавершение(Ответ, ПараметрыЗаписи) Экспорт 
	
	Если Ответ = КодВозвратаДиалога.Да тогда
		ПоказатьОповещениеПользователя("Информация",, "Выполняется реструктуризация связанных данных...", БиблиотекаКартинок.Информация32);
		ПараметрыЗаписи.Вставить("ВыполнитьРеструктуризациюСвязанныхДанных", Истина);
		Записать(ПараметрыЗаписи);
	КонецЕсли;	
	
КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	Если Объект.ТипЗначения.СодержитТип(Тип("СправочникСсылка.ЗначенияСвойствОбъектов")) Тогда
		ТекущийОбъект.СклоненияПредмета = ЕдинственноеЧислоПредмета + Символы.ПС + МножественноеЧислоПредмета;
	Иначе
		ТекущийОбъект.СклоненияПредмета = "";
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПриЗаписиНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	Перем ВыполнитьРеструктуризацию;
	
	Если ПараметрыЗаписи.Свойство("ВыполнитьРеструктуризациюСвязанныхДанных", ВыполнитьРеструктуризацию) 
		И ВыполнитьРеструктуризацию = Истина тогда
		нсиРеструктуризацияТехническихХарактеристик.РеструктуризацияСвязанныхДанных(
			Объект.Ссылка, "нсиУниверсальныйФункциональныйСправочник", "нсиХарактеристикиУниверсальногоСправочника",
			Объект.ТипЗначения, Отказ);
			
		Если Не Отказ тогда
			ПараметрыЗаписи.Вставить("ВыполненаРеструктуризация", Истина);			
		КонецЕсли;		
	КонецЕсли;	
	
	ПараметрыЗаписи.Вставить("Отказ", Отказ);
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	
	Перем Отказ;
	
	Если ПараметрыЗаписи.Свойство("Отказ", Отказ) И НЕ Отказ тогда
		Если ПараметрыЗаписи.Свойство("ВыполненаРеструктуризация") тогда
			ПоказатьОповещениеПользователя("Информация",, "Реструктуризация связанных данных выполнена успешно.", БиблиотекаКартинок.Информация32);		
		КонецЕсли;	
		Если ПараметрыЗаписи.Свойство("Закрыть") тогда
			Закрыть();
		КонецЕсли;	
	КонецЕсли;	
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Если Объект.Ссылка.Пустая() И НЕ ЗначениеЗаполнено(Объект.ВидКлассификатора) Тогда 
		ПоказатьПредупреждение(,"Установите отбор по виду классификатора!");
		Отказ = Истина;
	КонецЕсли;
	
	Если НЕ Элементы.Найти("ФормаЗаписатьИЗакрыть1") = Неопределено тогда
		Элементы.ФормаЗаписатьИЗакрыть1.КнопкаПоУмолчанию = Истина;
	КонецЕсли;	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	Если Модифицированность тогда
		ПоказатьВопрос(Новый ОписаниеОповещения("ПередЗакрытиемЗавершение", ЭтотОбъект),
			"Данные были изменены. Сохранить изменения?", 
			РежимДиалогаВопрос.ДаНетОтмена);		
			
		Отказ = Истина;
	КонецЕсли;	
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытиемЗавершение(Ответ, ДополнительныеПараметры) Экспорт
	
	Если Ответ = КодВозвратаДиалога.Да тогда
		Записать(Новый Структура("Закрыть", Истина));
	ИначеЕсли Ответ = КодВозвратаДиалога.Нет тогда
		Модифицированность = Ложь;
		Закрыть();
	КонецЕсли;	
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ЗаписатьИЗакрытьНаКлиенте(Команда)
	Записать(Новый Структура("Закрыть", Истина));	
КонецПроцедуры

&НаКлиенте
Процедура ЗаписатьНаКлиенте(Команда)
	Записать();	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ТипЗначенияПриИзменении(Элемент)
	
	Если Объект.ТипЗначения.СодержитТип(Тип("СправочникСсылка.нсиУниверсальныйФункциональныйСправочник"))
		И Объект.ТипЗначения.СодержитТип(Тип("СправочникСсылка.нсиУниверсальныйКлассификатор"))
		Тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"Типы 'Универсальный функциональный справочник' и 'Универсальный классификатор' не могут одновременно участвовать в составном типе"
		);
		
		Объект.ТипЗначения = Новый ОписаниеТипов;
		
	КонецЕсли;	
	
	ОчиститьВидСправочника();

	УправлениеВидимостью();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура УправлениеВидимостью()
	
	Если Объект.ТипЗначения.СодержитТип(Тип("СправочникСсылка.нсиУниверсальныйФункциональныйСправочник")) Тогда
		
		Элементы.ВидСправочника.Видимость = Истина;
		
		ПараметрВыбора = Новый ПараметрВыбора("Отбор.ВидСправочника", Перечисления.нсиВидыСправочников.ФункциональныйСправочник);
		МассивПараметров = Новый Массив;
		МассивПараметров.Добавить(ПараметрВыбора);
		НовыеПараметры = Новый ФиксированныйМассив(МассивПараметров);
		Элементы.ВидСправочника.ПараметрыВыбора = НовыеПараметры;
		
	
	ИначеЕсли Объект.ТипЗначения.СодержитТип(Тип("СправочникСсылка.нсиУниверсальныйКлассификатор")) Тогда
		
		Элементы.ВидСправочника.Видимость = Истина;
		
		ПараметрВыбора = Новый ПараметрВыбора("Отбор.ВидСправочника", Перечисления.нсиВидыСправочников.Классификатор);
		МассивПараметров = Новый Массив;
		МассивПараметров.Добавить(ПараметрВыбора);
		НовыеПараметры = Новый ФиксированныйМассив(МассивПараметров);
		Элементы.ВидСправочника.ПараметрыВыбора = НовыеПараметры;
		
	Иначе
		Элементы.ВидСправочника.Видимость = Ложь;
	КонецЕсли;

КонецПроцедуры

&НаСервере
Процедура ОчиститьВидСправочника()
	
	Объект.ВидСправочника = Справочники.нсиВидыСправочников.ПустаяСсылка();
		
КонецПроцедуры

#КонецОбласти