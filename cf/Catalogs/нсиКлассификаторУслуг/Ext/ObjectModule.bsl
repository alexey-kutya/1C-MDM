﻿
#Область ПрограммныйИнтерфейс

// Процедура копирует характеристики услуг из класса ПредметОригинал, копирует шаблон наименования.
// Параметры:
//	ПредметОригинал - ссылка на класс, с которого копируются характеристики.
//
Процедура СкопироватьХарактеристикиОригинала(ПредметОригинал) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	нсиХарактеристикиУслуг.Ссылка
		|ИЗ
		|	ПланВидовХарактеристик.нсиХарактеристикиУслуг КАК нсиХарактеристикиУслуг
		|ГДЕ
		|	нсиХарактеристикиУслуг.Класс = &ПредметОригинал";
	
	Запрос.УстановитьПараметр("ПредметОригинал", ПредметОригинал);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		// Копия характеристики.
		НоваяХарактеристика = ПланыВидовХарактеристик.нсиХарактеристикиМТР.СоздатьЭлемент();
		ЗаполнитьЗначенияСвойств(НоваяХарактеристика, Выборка.Ссылка,, "Код,Класс,Родитель");
		НоваяХарактеристика.УстановитьНовыйКод();
		Если ЭтоНовый() тогда
			НоваяХарактеристика.Класс = ПолучитьСсылкуНового();
		Иначе 	
			НоваяХарактеристика.Класс = Ссылка;
		КонецЕсли;
		НоваяХарактеристика.Записать();
		
		// Замена характеристик в шаблонах наименований.
		НайденыеСтроки = НастройкиШаблоновНаименований.НайтиСтроки(Новый Структура("ЭлементНаименования", Выборка.Ссылка));
		Для Каждого НайденнаяСтрока Из НайденыеСтроки цикл
			НайденнаяСтрока.ЭлементНаименования = НоваяХарактеристика.Ссылка;
		КонецЦикла;	
	КонецЦикла;
		
КонецПроцедуры	

// Процедура копирует или изменяет характеристки текущего класса из класса ПредметМакет.
// Параметры:
//	ПредметМакет - ссылка на класс - источник характеристик.
//
Процедура ОбновитьХарактеристикиПоМакету(ПредметМакет) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	нсиХарактеристикиУслугМакет.Ссылка КАК Макет,
		|	нсиХарактеристикиУслугОригинал.Ссылка КАК Оригинал,
		|	нсиХарактеристикиУслугОригинал.ПометкаУдаления КАК Порядок
		|ИЗ
		|	ПланВидовХарактеристик.нсиХарактеристикиУслуг КАК нсиХарактеристикиУслугМакет
		|		ЛЕВОЕ СОЕДИНЕНИЕ ПланВидовХарактеристик.нсиХарактеристикиУслуг КАК нсиХарактеристикиУслугОригинал
		|		ПО нсиХарактеристикиУслугМакет.НаименованиеПоКлассификатору = нсиХарактеристикиУслугОригинал.НаименованиеПоКлассификатору
		|			И (нсиХарактеристикиУслугОригинал.Класс = &ПредметОригинал)
		|ГДЕ
		|	нсиХарактеристикиУслугМакет.Класс = &ПредметМакет
		|
		|УПОРЯДОЧИТЬ ПО
		|	Макет,
		|	Порядок
		|ИТОГИ ПО
		|	Макет";
	
	Запрос.УстановитьПараметр("ПредметМакет", ПредметМакет);
	Запрос.УстановитьПараметр("ПредметОригинал", Ссылка);
	
	ВыборкаМакет = Запрос.Выполнить().Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаМакет.Следующий() Цикл
		
		ВыборкаОригинал = ВыборкаМакет.Выбрать();
		Если ВыборкаОригинал.Следующий() Тогда 
			
			Если ВыборкаОригинал.Оригинал = NULL тогда
				ХарактеристикаОбъект = ПланыВидовХарактеристик.нсиХарактеристикиУслуг.СоздатьЭлемент();
				ЗаполнитьЗначенияСвойств(ХарактеристикаОбъект, ВыборкаМакет.Макет,, "Код,Класс,Родитель");
				ХарактеристикаОбъект.УстановитьНовыйКод();
				ХарактеристикаОбъект.Класс = Ссылка;
			Иначе 
				ХарактеристикаОбъект = ВыборкаОригинал.Оригинал.ПолучитьОбъект();
				ЗаполнитьЗначенияСвойств(ХарактеристикаОбъект, ВыборкаМакет.Макет,, "Код,Класс,Родитель");
			КонецЕсли;
			
			ХарактеристикаОбъект.Записать();
			
			// Замена характеристик в шаблонах наименований.
			НайденыеСтроки = НастройкиШаблоновНаименований.НайтиСтроки(Новый Структура("ЭлементНаименования", ВыборкаМакет.Макет));
			Для Каждого НайденнаяСтрока Из НайденыеСтроки цикл
				НайденнаяСтрока.ЭлементНаименования = ХарактеристикаОбъект.Ссылка;
			КонецЦикла;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры	

// Процедура удаляет характеристики объекта, если это макет.
//
Процедура УдалитьХарактеристики() Экспорт
	
	Если Не ЭтоМакет тогда
		Возврат
	КонецЕсли;	
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	нсиХарактеристикиУслуг.Ссылка
		|ИЗ
		|	ПланВидовХарактеристик.нсиХарактеристикиУслуг КАК нсиХарактеристикиУслуг
		|ГДЕ
		|	нсиХарактеристикиУслуг.Класс = &Предмет";
	
	Запрос.УстановитьПараметр("Предмет", Ссылка);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		ОбъектДляУдаления = Выборка.Ссылка.ПолучитьОбъект();	
		ОбъектДляУдаления.ОбменДанными.Загрузка = Истина;
		ОбъектДляУдаления.Удалить();
	КонецЦикла;
		
КонецПроцедуры	

#КонецОбласти

#Область ОбработчикиСобытий

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	
	Если ТипЗнч(ДанныеЗаполнения) = Тип("СправочникСсылка.нсиКлассификаторУслуг") Тогда
		
		// заполнение реквизитов
		ЗаполнитьЗначенияСвойств(ЭтотОбъект, ДанныеЗаполнения, , "Владелец,Код,ЭтоМакет");
		
		// заполнение табличных частей
		НастройкиШаблоновНаименований.Загрузить(ДанныеЗаполнения.НастройкиШаблоновНаименований.Выгрузить());
		
	КонецЕсли;

КонецПроцедуры

Процедура ПередЗаписью(Отказ)
	Если ОбменДанными.Загрузка Тогда 
		Возврат;
	КонецЕсли;
	
	Если ЭтоМакет тогда
		ДополнительныеСвойства.Вставить("СШПНеобрабатывать", Истина); 
	КонецЕсли;	
	
	нсиОбщегоНазначения.УдалитьПробелыИзСтроки(Наименование);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#КонецОбласти
