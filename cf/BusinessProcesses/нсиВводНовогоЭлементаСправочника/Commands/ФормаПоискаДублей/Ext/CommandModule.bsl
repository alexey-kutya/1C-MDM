﻿#Область ПрограммныйИнтерфейс

&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
	Если Найти(ПараметрыВыполненияКоманды.Источник.ИмяФормы,".Действие")>0
		И Найти(ПараметрыВыполненияКоманды.Источник.ИмяФормы,"БизнесПроцесс.Задание")=0 Тогда
		Предмет = ПараметрыВыполненияКоманды.Источник.Объект.Предмет;
		ИмяСправочника = ПараметрыВыполненияКоманды.Источник.Задание.ИмяСправочника;
		
		Если ТипЗнч(ИмяСправочника) = Тип("СправочникСсылка.нсиВидыСправочников") Тогда 
			ИмяСправочникаУХ = нсиУниверсальноеХранилищеПовтИсп.ПолучитьИмяСправочникаХранилища(ИмяСправочника);
			ИмяФормы = "Справочник."+ИмяСправочникаУХ+".ФормаСписка";
		Иначе
			ИмяФормы = "Справочник."+ИмяСправочника+".ФормаСписка";
		КонецЕсли;
	ИначеЕсли  Найти(ПараметрыВыполненияКоманды.Источник.ИмяФормы,"Задача.ЗадачаИсполнителя")>0 Тогда 
			Задача = ПараметрыВыполненияКоманды.Источник.Элементы.Список.ТекущаяСтрока;
			Если Задача<>Неопределено Тогда 
				ПараметрыФормы = ПолучитьПараметрыФормы(Задача);
				Если НЕ ЗначениеЗаполнено(ПараметрыФормы) Тогда 
					Возврат;
				КонецЕсли;
				Предмет = ПараметрыФормы.Предмет;
				ИмяСправочника = ПараметрыФормы.ИмяСправочника;
				
				Если ТипЗнч(ИмяСправочника) = Тип("СправочникСсылка.нсиВидыСправочников") Тогда 
					ИмяСправочникаУХ = нсиУниверсальноеХранилищеПовтИсп.ПолучитьИмяСправочникаХранилища(ИмяСправочника);
					ИмяФормы = "Справочник."+ИмяСправочникаУХ+".ФормаСписка";
				Иначе
					ИмяФормы = ПараметрыФормы.ИмяФормы;
				КонецЕсли;
			Иначе
				ПоказатьПредупреждение(,"Не выбрана задача!");
				Возврат;
			КонецЕсли;
	Иначе
		Возврат;
	КонецЕсли;
	
	Если ТипЗнч(ИмяСправочника) = Тип("Строка") Тогда 
		ПараметрыФормы = Новый Структура("ТекущаяСтрока,РежимПоискаДубля", Предмет,Истина);
	Иначе
		ПараметрыФормы = Новый Структура(
			"ТекущаяСтрока,РежимПоискаДубля,Отбор",
			Предмет,Истина,
			новый Структура("Владелец",ИмяСправочника)
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
			ЗаполнитьОтбор(Форма.Список.Отбор,Отбор,Предмет);
		Исключение
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
Функция ПолучитьПараметрыФормы(Задача)
	Если ТипЗнч(Задача) <> Тип("ЗадачаСсылка.ЗадачаИсполнителя") Тогда 
		Возврат Неопределено;
	КонецЕсли;
	
	Если ТипЗнч(Задача.Бизнеспроцесс) = Тип("БизнесПроцессСсылка.Задание") Тогда 
		Возврат Неопределено;
	КонецЕсли;
	
	Результат = новый Структура("Предмет,ИмяФормы,ИмяСправочника",
		Задача.Предмет,
		"Справочник."+Задача.БизнесПроцесс.ИмяСправочника+".ФормаСписка",
		Задача.БизнесПроцесс.ИмяСправочника
	);
	Возврат Результат;
КонецФункции

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

#КонецОбласти
