﻿&НаКлиенте
Процедура Согласование(Команда)
	
	Если Записать() Тогда
		Если РучнойРежим Тогда
			IDLenght = IDLenght(Объект.Ссылка);
			Если ПустаяСтрока(Объект.GlobalID)
				ИЛИ ПустаяСтрока(Объект.Наименование)
				Тогда
				Сообщить("Действие не выполнено !");
			    Сообщить("Поля Global ID и Global Name должны быть заполнены");
				Возврат;
			ИначеЕсли НЕ СтрДлина(СокрЛП(Объект.GlobalID)) = IDLenght Тогда
				Сообщить("Действие не выполнено !");
			    Сообщить(СтрШаблон("Длина Global ID должна быть %1",IDLenght));
				Возврат;
			ИначеЕсли НЕ АтрибутыЗаполнены() Тогда
				Сообщить("Действие не выполнено !");
			    Сообщить("В режиме утверждения Global ID без согласования не допускается создание новых атрибутов.");
				Возврат;
			Иначе	
				Объект.State = ПредопределенноеЗначение("Перечисление.States.Approved");
				Объект.TimeStamp = ТекущаяДата();
			КонецЕсли; 
		Иначе
			InteractiveMode = истина;
			СогласованиеНаСервере(InteractiveMode);
		КонецЕсли; 
		
		Если Записать() Тогда
			Закрыть(Объект.Ссылка);
		КонецЕсли; 
	Иначе
		Сообщить("Действие не выполнено !");
	КонецЕсли; 
	
КонецПроцедуры

&НаСервере
Функция АтрибутыЗаполнены()
	
	АтрибутыЗаполнены = Истина;
	
	interface = MDMСервер.interface(Объект.Ссылка);
	
	РеквизитыДляЗапросаНового = interface.РеквизитыДляЗапросаНового();
								
	Для каждого Реквизит Из РеквизитыДляЗапросаНового Цикл
		
		АтрибутыЗаполнены = АтрибутыЗаполнены И ЗначениеЗаполнено(Объект[Реквизит.Ключ]);
		
	КонецЦикла;
	
	Возврат АтрибутыЗаполнены;

КонецФункции

&НаСервереБезКонтекста
Функция IDLenght(ОбъектСсылка)

	Возврат MDMСервер.interface(ОбъектСсылка).IDLenght();

КонецФункции // IDLenght()
 
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Параметры.Свойство("РучнойРежим", РучнойРежим);
	
	СтруктураGlobalSKU = Неопределено;
	Если Параметры.Свойство("СтруктураGlobalSKU", СтруктураGlobalSKU) Тогда
		ЗаполнитьЗначенияСвойств(Объект, СтруктураGlobalSKU);
	Иначе
		Элементы.ГруппаКнопокОтправкиНаСогласование.Видимость = Ложь;
	КонецЕсли;
	
	УстановитьВидимостьЭлементов();
	УстановитьДоступностьЭлементов();
	
КонецПроцедуры

&НаСервере
Процедура УстановитьВидимостьЭлементов()
	
	interface = MDMСервер.interface(Объект.Ссылка);
	
	Элементы.ОтправитьНаСогласование.Заголовок = ?(РучнойРежим,"Утвердить без запроса","Отправить на согласование");
	
	РеквизитыДляЗапросаНового = interface.РеквизитыДляЗапросаНового();
								
	Для каждого Реквизит Из РеквизитыДляЗапросаНового Цикл
		
		ИмяАтрибута = Реквизит.Ключ;
		Заполнено = ЗначениеЗаполнено(Объект[ИмяАтрибута]);
		
		Элементы[ИмяАтрибута].Видимость = Заполнено;
		Элементы[ИмяАтрибута+"Код"].Видимость = Заполнено;
		Элементы[ИмяАтрибута+"New"].Видимость = НЕ Заполнено;
		Элементы[ИмяАтрибута+"NewPic"].Видимость = НЕ Заполнено;
		
	КонецЦикла; 

КонецПроцедуры // УстановитьВидимостьЭлементов()

&НаСервере
Процедура УстановитьДоступностьЭлементов()

	interface = MDMСервер.interface(Объект.Ссылка);
	
	Для каждого ИдентификаторGlobal Из interface.ИдентификаторыGlobal() Цикл
		Элементы[ИдентификаторGlobal.Ключ].ТолькоПросмотр = НЕ РучнойРежим;
	КонецЦикла; 

КонецПроцедуры // УстановитьДоступностьЭлементов()
 
&НаСервере
Процедура СогласованиеНаСервере(InteractiveMode)
	
	ЗначениеВРеквизитФормы(GlobEx.ОтправитьНаСогласование(РеквизитФормыВЗначение("Объект"), InteractiveMode), "Объект");
	
КонецПроцедуры

&НаКлиенте
Процедура ЗакрытьФорму(Команда)
	Закрыть();
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, СтандартнаяОбработка)
	
	Если Модифицированность Тогда
		СтандартнаяОбработка = Ложь;
		Закрыть();
	КонецЕсли;
	
КонецПроцедуры
