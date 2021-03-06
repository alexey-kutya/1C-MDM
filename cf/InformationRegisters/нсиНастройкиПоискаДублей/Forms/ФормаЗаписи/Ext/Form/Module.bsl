﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	нсиБизнесПроцессы.ЗаполнитьСписокСправочниковВедущихсяПоЗаявкам(Элементы.ИмяСправочника.СписокВыбора);
	ИнициализироватьКомпоновщикНастроек();
	УправлениеВИдимостьюИДоступом();
КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	ТекущийОбъект.НастройкаОтбора = нсиСохранениеНастроекСписков.СериализоватьОтбор(КомпоновщикНастроек.Настройки.Отбор);
	ТекущийОбъект.ПредставлениеОтбора = Строка(КомпоновщикНастроек.Настройки.Отбор);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура УправлениеВИдимостьюИДоступом()
	Элементы.Группа1.Доступность = ЗначениеЗаполнено(Запись.ИмяСправочника);
КонецПроцедуры

&НаСервере
Процедура ИнициализироватьКомпоновщикНастроек()
	Если НЕ ЗначениеЗаполнено(Запись.ИмяСправочника) Тогда 
		Возврат;
	КонецЕсли;
	
	Если ТипЗнч(Запись.ИмяСправочника)  = Тип("Строка") Тогда 
		СписокРеквизитов = "Ссылка";
		ТекстЗапроса = "ВЫБРАТЬ "+СписокРеквизитов+" ИЗ Справочник."+Запись.ИмяСправочника;
	Иначе
		пМетаданные = нсиУниверсальноеХранилище.ПолучитьМетаданные(Запись.ИмяСправочника);
		ТекстЗапроса = нсиУниверсальноеХранилищеФормыСервер.ПолучитьТекстЗапроса(пМетаданные)
	КонецЕсли;
	
	
	СхемаКомпоновкиДанных 	= Новый СхемаКомпоновкиДанных;
	
	// новый источник данных
	ИсточникиДанных 	= СхемаКомпоновкиДанных.ИсточникиДанных.Добавить();
	ИсточникиДанных.Имя 				= "ИсточникиДанных1";
	ИсточникиДанных.ТипИсточникаДанных 	= "Local";
	
	// новый запрос по источнику
	НаборДанныхЗапрос 	= СхемаКомпоновкиДанных.НаборыДанных.Добавить(Тип("НаборДанныхЗапросСхемыКомпоновкиДанных"));
	НаборДанныхЗапрос.ИсточникДанных 	= "ИсточникиДанных1";
	НаборДанныхЗапрос.Имя 				= "Запрос";
	НаборДанныхЗапрос.Запрос 			= ТекстЗапроса;
	
	АдресКомпоновки = ПоместитьВоВременноеХранилище(СхемаКомпоновкиДанных, УникальныйИдентификатор);	
	КомпоновщикНастроек.Инициализировать(Новый ИсточникДоступныхНастроекКомпоновкиДанных(АдресКомпоновки));
	
	Если ЗначениеЗаполнено(Запись.ИмяСправочника) Тогда 
		Попытка
			нсиСохранениеНастроекСписков.ДесериализоватьОтбор(Запись.НастройкаОтбора,КомпоновщикНастроек.Настройки.Отбор);
		Исключение
		КонецПопытки;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ИмяСправочникаПриИзменении(Элемент)
	ИнициализироватьКомпоновщикНастроек();
	УправлениеВИдимостьюИДоступом();
КонецПроцедуры

#КонецОбласти
