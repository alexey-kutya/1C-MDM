﻿#Область ПрограммныйИнтерфейс

&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
	ИмяСправочника = ПолучитьИмяСправочника(ПараметрКоманды);
	
	Если ТипЗнч(ПараметрКоманды) = Тип("СправочникСсылка.нсиУниверсальныйФункциональныйСправочник") Тогда 
		ИмяСправочникаУХ = нсиУниверсальноеХранилищеПовтИсп.ПолучитьИмяСправочникаХранилища(ИмяСправочника);
		ИмяФормы = "Справочник."+ИмяСправочникаУХ+".ФормаСписка";
	Иначе
		ИмяФормы = "Справочник."+ИмяСправочника+".ФормаСписка";
	КонецЕсли;
	
	Если ТипЗнч(ИмяСправочника) = Тип("Строка") Тогда                                       
		ПараметрыФормы = Новый Структура("ТекущаяСтрока,РежимПоискаДубля", ПараметрКоманды, Истина);
	Иначе
		ПараметрыФормы = Новый Структура(
			"ТекущаяСтрока,РежимПоискаДубля,Отбор",
			ПараметрКоманды, Истина, новый Структура("Владелец",ИмяСправочника)
										);
	КонецЕсли;
	
	Форма = ПолучитьФорму(ИмяФормы,
		ПараметрыФормы,
		ПараметрыВыполненияКоманды.Источник, 
		ПараметрыВыполненияКоманды.Уникальность, 
		ПараметрыВыполненияКоманды.Окно);
		
	Форма.Список.Отбор.Элементы.Очистить();
	НастройкаОтбора = ПолучитьНастройкуОтбора(ИмяСправочника);
	Если НастройкаОтбора<>Неопределено Тогда 
		Попытка
			Отбор = Форма.Список.Отбор;
			нсиСохранениеНастроекСписков.ДесериализоватьОтбор(НастройкаОтбора,Отбор);
			ЗаполнитьОтбор(Форма.Список.Отбор,Отбор,ПараметрКоманды);
		Исключение
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ОписаниеОшибки());	
		КонецПопытки;
	КонецЕсли;
	
	Если Форма.Элементы.Найти("ГруппаСтандартная") <> Неопределено Тогда 
		Форма.Элементы.ГруппаСтандартная.Видимость 				= Ложь;
	КонецЕсли;
	
	Если Форма.Элементы.Найти("ГруппаЗаявок") <> Неопределено Тогда 
		Форма.Элементы.ГруппаЗаявок.Видимость 					= Ложь;
	КонецЕсли;
	
	Если Форма.Элементы.Найти("СтатусыОбработкиСправочников") <> Неопределено Тогда 
		Форма.Элементы.СтатусыОбработкиСправочников.Видимость 	= Ложь;
	КонецЕсли;
	
	Форма.Элементы.Список.Обновить();
	
	Форма.Открыть();                          
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ЗаполнитьОтбор(ОтборФормы,Отбор, Предмет)
	ИменаРеквизитов = "";
	
	ПолучитьИменаРеквизитов(Отбор,ИменаРеквизитов);
	ЗначенияРеквизитов = ПолучитьЗначенияРеквизитов(Предмет, ИменаРеквизитов);
	ЗаполнитьПравыеЗначенияЭлементовОтбора(Отбор,ЗначенияРеквизитов);
	СкопироватьОтбор(ОтборФормы,Отбор);
КонецПроцедуры

&НаКлиенте
Процедура ПолучитьИменаРеквизитов(ЭлементОтбора,ИменаРеквизитов)
	Если ТипЗнч(ЭлементОтбора) = Тип("ОтборКомпоновкиДанных") ИЛИ
		ТипЗнч(ЭлементОтбора) = Тип("ГруппаЭлементовОтбораКомпоновкиДанных") Тогда 
		
		Для Каждого Э Из ЭлементОтбора.Элементы Цикл
			ПолучитьИменаРеквизитов(Э,ИменаРеквизитов);
		КонецЦикла;
		
	Иначе
		ИменаРеквизитов = ИменаРеквизитов + ?(ПустаяСтрока(ИменаРеквизитов),"",",")+Строка(ЭлементОтбора.ЛевоеЗначение);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьПравыеЗначенияЭлементовОтбора(ЭлементОтбора,ЗначенияРеквизитов)
	Если ТипЗнч(ЭлементОтбора) = Тип("ОтборКомпоновкиДанных") ИЛИ
		ТипЗнч(ЭлементОтбора) = Тип("ГруппаЭлементовОтбораКомпоновкиДанных") Тогда 
		
		Для Каждого Э Из ЭлементОтбора.Элементы Цикл
			ЗаполнитьПравыеЗначенияЭлементовОтбора(Э,ЗначенияРеквизитов);
		КонецЦикла;
		
	Иначе
		Если НЕ ЗначениеЗаполнено(ЭлементОтбора.ПравоеЗначение)
			ИЛИ ЭлементОтбора.ПравоеЗначение = "00000000-0000-0000-0000-000000000000" Тогда 
			ЭлементОтбора.ПравоеЗначение  = ЗначенияРеквизитов[Строка(ЭлементОтбора.ЛевоеЗначение)];
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура СкопироватьОтбор(Приемник,Источник)
	Если ТипЗнч(Источник) = Тип("ОтборКомпоновкиДанных")
		ИЛИ ТипЗнч(Источник) = Тип("ГруппаЭлементовОтбораКомпоновкиДанных") Тогда 
		Для Каждого ЭИсточник Из Источник.Элементы Цикл
			ЭПриемник = Приемник.Элементы.Добавить(ТипЗнч(ЭИсточник));
			ЗаполнитьЗначенияСвойств(ЭПриемник,ЭИсточник);
			СкопироватьОтбор(ЭПриемник,ЭИсточник);
		КонецЦикла;
	Иначе
		ЗаполнитьЗначенияСвойств(Приемник,Источник);
	КонецЕсли;
КонецПроцедуры

&НаСервере
Функция ПолучитьНастройкуОтбора(ИмяСправочника)
	МЗ = РегистрыСведений.нсиНастройкиПоискаДублей.СоздатьМенеджерЗаписи();
	МЗ.ИмяСправочника = ИмяСправочника;
	МЗ.Прочитать();
	Если МЗ.Выбран() Тогда
		Возврат МЗ.НастройкаОтбора;
	Иначе
		Возврат Неопределено;
	КонецЕсли;
КонецФункции

&НаСервере
Функция ПолучитьЗначенияРеквизитов(Ссылка, ИменаРеквизитов)
	
	Результат = Новый Соответствие();
	ИменаРеквизитов_ = СтрЗаменить(ИменаРеквизитов,",",Символы.ПС);
	КоличествоРеквизитов = СтрЧислоСтрок(ИменаРеквизитов_);
	
	Если ТипЗнч(Ссылка) <> Тип("СправочникСсылка.нсиУниверсальныйФункциональныйСправочник")
		И ТипЗнч(Ссылка) <> Тип("СправочникСсылка.нсиУниверсальныйКлассификатор") Тогда 
	
		Запрос = Новый Запрос;
		Запрос.Текст =
			"ВЫБРАТЬ
			|	" + ИменаРеквизитов + "
			|ИЗ
			|	" + Ссылка.Метаданные().ПолноеИмя() + " КАК Таблица
			|ГДЕ
			|	Таблица.Ссылка = &Ссылка";
		Запрос.УстановитьПараметр("Ссылка", Ссылка);
		
		Выборка = Запрос.Выполнить().Выбрать();
		Выборка.Следующий();
		Для Сч = 1 По КоличествоРеквизитов Цикл
			Если ТипЗнч(Выборка[Сч-1]) <> Тип("РезультатЗапроса") Тогда 
				Результат.Вставить(СтрПолучитьСтроку(ИменаРеквизитов_,Сч),Выборка[Сч-1]);
			КонецЕсли;
		КонецЦикла;
	Иначе
		пМетаданные = нсиУниверсальноеХранилище.ПолучитьМетаданные(Ссылка.Владелец);
		пОбъект = нсиУниверсальноеХранилище.ПолучитьОбъект(пМетаданные,Ссылка);
		Для Сч = 1 По КоличествоРеквизитов Цикл
			Имяреквизита = СтрПолучитьСтроку(ИменаРеквизитов_,Сч);
			Если ИмяРеквизита = "Наименование"
				ИЛИ ИмяРеквизита = "Код"
				ИЛИ ИмяРеквизита = "ПометкаУдаления"
				ИЛИ ИмяРеквизита = "Родитель"
				ИЛИ ИмяРеквизита = "Владелец" Тогда
				Результат.Вставить(Имяреквизита,Ссылка[Имяреквизита]);
			ИначеЕсли Ссылка.Метаданные().Реквизиты.Найти(ИмяРеквизита)<>Неопределено Тогда 
				Результат.Вставить(Имяреквизита,Ссылка[Имяреквизита]);
			ИначеЕсли пОбъект.Свойство(Имяреквизита) Тогда 
				Результат.Вставить(Имяреквизита,пОбъект[Имяреквизита]);
			КонецЕсли;
		КонецЦикла;
		
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

&НаСервере
Функция ПолучитьИмяСправочника(Ссылка)
	
	Если ТипЗнч(Ссылка)  = Тип("СправочникСсылка.нсиУниверсальныйФункциональныйСправочник") Тогда
		Возврат Ссылка.Владелец;
	Иначе 
		Возврат Ссылка.Метаданные().Имя;
	КонецЕсли;
	
КонецФункции

#КонецОбласти
