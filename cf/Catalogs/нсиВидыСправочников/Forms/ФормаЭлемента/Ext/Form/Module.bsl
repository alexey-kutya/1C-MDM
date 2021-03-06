﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Если не ЗначениеЗаполнено(Объект.Ссылка) и Объект.Реквизиты.Количество() = 0 Тогда
		Объект.ТипНаименования = "Строка(50)";
		ЭтаФорма.Модифицированность = Ложь;
	КонецЕсли;
	МодифицированаСтруктура = Ложь;
	ЗадаватьВопросОСохраненииПриЗакрытии = Истина;
	
	УстановитьДоступность();
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	Тип1 = "";
	Если ТипЗнч(Объект.ВладелецСправочника)=Тип("Строка") Тогда
		Тип1 = "Справочник";
	ИначеЕсли ТипЗнч(Объект.ВладелецСправочника)=Тип("СправочникСсылка.нсиВидыСправочников") Тогда
		Тип1 = "Хранилище";
	КонецЕсли;
	ТипВладельца = нсиУниверсальноеХранилище.ПолучитьПредставлениеТипа(Тип1, Объект.ВладелецСправочника);
	
	Классификатор = нсиУниверсальноеХранилище.ПолучитьПредставлениеТипа("Хранилище", Объект.Классификатор);
	
	Для каждого Реквизит Из Объект.Реквизиты Цикл
		Реквизит.Тип = нсиУниверсальноеХранилище.ПолучитьПредставлениеТипа(Реквизит.Тип1, Реквизит.Тип2);
		Реквизит.ИндексКартинки = 0;
	КонецЦикла;
	
	СоздатьЭлементы();
	
КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	ЗаписатьПодчиненныеЭлементы(Отказ);
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	МодифицированаСтруктура = Ложь;
	Для каждого Реквизит Из Объект.Реквизиты Цикл
		Реквизит.Тип = нсиУниверсальноеХранилище.ПолучитьПредставлениеТипа(Реквизит.Тип1, Реквизит.Тип2);
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, СтандартнаяОбработка)
	Если ЗадаватьВопросОСохраненииПриЗакрытии Тогда 
		Если Модифицированность Тогда 
			Отказ = Истина;
			ОписаниеОповещения = новый ОписаниеОповещения("ОбработкаОтветаСохранитьИзменения",ЭтаФорма);
			ПоказатьВопрос(ОписаниеОповещения,"Сохранить изменения ?",РежимДиалогаВопрос.ДаНет,,КодВозвратаДиалога.Да);
		КонецЕсли;
	Иначе
		СтандартнаяОбработка = Ложь;
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыРеквизиты

&НаКлиенте
Процедура РеквизитыТипНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	ТипНачалоВыбора(Элемент, "Реквизиты");	
КонецПроцедуры

&НаКлиенте
Процедура РеквизитыТипОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	ТипОбработкаВыбора("Реквизиты", СтандартнаяОбработка, ВыбранноеЗначение);
КонецПроцедуры

&НаКлиенте
Процедура РеквизитыПриНачалеРедактирования(Элемент, НоваяСтрока, Копирование)
	ПриНачалеРедактирования(Элемент,НоваяСтрока,Копирование,"Реквизит");
КонецПроцедуры

&НаКлиенте
Процедура РеквизитыПослеУдаления(Элемент)
	МодифицированаСтруктура = Истина;
КонецПроцедуры

#КонецОбласти


#Область ОбработчикиСобытийЭлементовТаблицыФормыДинамические

&НаКлиенте
Процедура Подключаемый_ТипНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	// Имя элемента состоит из имени тч и имени элемента.
	ИмяТЧ = Лев(Элемент.Имя,СтрДлина(Элемент.Имя)-3);
	ТипНачалоВыбора(Элемент, ИмяТЧ);	
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ТипОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	// Имя элемента состоит из имени тч и имени элемента.
	ИмяТЧ = Лев(Элемент.Имя,СтрДлина(Элемент.Имя)-3);
	ТипОбработкаВыбора(ИмяТЧ, СтандартнаяОбработка, ВыбранноеЗначение);
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ПриАктивизацииСтроки(Элемент)
	Если Элемент.ТекущиеДанные=Неопределено Тогда
		Возврат;
	КонецЕсли;
	ИмяТч = Элемент.Имя;
	элНаименование 	= ИмяТч+"Наименование";
	элТип 			= ИмяТч+"Тип";	
	Элементы[элНаименование].ТолькоПросмотр = Ложь;
	Элементы[элТип].ТолькоПросмотр = Ложь;
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ПриНачалеРедактирования(Элемент, НоваяСтрока, Копирование)
	ПриНачалеРедактирования(Элемент,НоваяСтрока,Копирование,"Реквизит");
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ПослеУдаления(Элемент)
	МодифицированаСтруктура = Истина;
КонецПроцедуры

#КонецОбласти


#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ИерархическийПриИзменении(Элемент)
	Если НЕ Объект.Иерархический Тогда
		Для каждого стр из Объект.Реквизиты Цикл
			стр.ДляГруппы = Ложь;
		КонецЦикла;
	КонецЕсли;
	УстановитьДоступность();
КонецПроцедуры

&НаКлиенте
Процедура ВидСправочникаПриИзменении(Элемент)
	ВидСправочникаПриИзмененииНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура ИспользоватьПолноеНаименованиеПриИзменении(Элемент)
	УстановитьДоступность();
КонецПроцедуры

&НаСервере
Процедура ВидСправочникаПриИзмененииНаСервере()
	Если Объект.ВидСправочника=Перечисления.нсиВидыСправочников.ФункциональныйСправочник Тогда
		Объект.ВладелецСправочника = Неопределено;
		ТипВладельца = "";
	ИначеЕсли Объект.ВидСправочника=Перечисления.нсиВидыСправочников.ТабличнаяЧасть Тогда
		Объект.ВидИерархии = Перечисления.нсиВидыИерархииСправочников.ПустаяСсылка();
		Объект.Иерархический = Ложь;
		Объект.ТипКода = "Строка(4)";
		Если ТипЗнч(Объект.ВладелецСправочника)=Тип("Строка") Тогда
			Объект.ВладелецСправочника = Неопределено;
			ТипВладельца = "";
		КонецЕсли;
		Объект.ПредставлениеОбъекта = "";
		Объект.БыстрыйВыбор = Ложь;
		Объект.ОтборВФормеСписка = Ложь;
		Объект.ИспользоватьЗаявки = Ложь;
		Объект.ИспользоватьНормализацию = Ложь;
		Объект.ИспользоватьКлассификацию = Ложь;
		Объект.Классификатор = "";
		Объект.РеквизитПредставления = Неопределено;
		Классификатор = "";
		Объект.ИспользоватьПолноеНаименование = Ложь;
		Объект.ИспользоватьДопКлассификацию = Ложь;
	ИначеЕсли Объект.ВидСправочника=Перечисления.нсиВидыСправочников.Классификатор Тогда
		Объект.ИспользоватьНормализацию = Ложь;
		Объект.ИспользоватьКлассификацию = Ложь;
		Объект.Классификатор = "";
		Классификатор = "";
		Объект.ВидИерархии = Перечисления.нсиВидыИерархииСправочников.ИерархияЭлементов;
		Объект.ИспользоватьПолноеНаименование = Ложь;
		Объект.ИспользоватьДопКлассификацию = Ложь;
	КонецЕсли;
	УстановитьДоступность();
КонецПроцедуры

&НаКлиенте
Процедура ТипКодаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	ПараметрыФормы = Новый Структура("Тип1,Тип2,ОграничениеТипа", Объект.ТипКода, Неопределено, "Строка");
	ОткрытьФорму("Справочник.нсиВидыСправочников.Форма.ВыборТипа", ПараметрыФормы, Элемент);
КонецПроцедуры

&НаКлиенте
Процедура ТипКодаОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	Объект.ТипКода = нсиУниверсальноеХранилище.ПолучитьПредставлениеТипа(ВыбранноеЗначение.Тип1, ВыбранноеЗначение.Тип2);
	СтандартнаяОбработка = Ложь;
КонецПроцедуры

&НаКлиенте
Процедура ТипВладельцаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	Если Объект.ВидСправочника=ПредопределенноеЗначение("Перечисление.нсиВидыСправочников.ТабличнаяЧасть") Тогда
		ОграничениеТипа = "Хранилище";
	Иначе
		ОграничениеТипа = "Справочник,Хранилище";
	КонецЕсли;
	ПараметрыФормы = Новый Структура("Тип1,Тип2,ОграничениеТипа",
		?(ТипЗнч(Объект.ВладелецСправочника)=Тип("Строка"),"Справочник","Хранилище"), Объект.ВладелецСправочника, ОграничениеТипа);
	ОткрытьФорму("Справочник.нсиВидыСправочников.Форма.ВыборТипа", ПараметрыФормы, Элемент);
КонецПроцедуры

&НаКлиенте
Процедура ТипВладельцаОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ТипВладельца = нсиУниверсальноеХранилище.ПолучитьПредставлениеТипа(ВыбранноеЗначение.Тип1, ВыбранноеЗначение.Тип2);
	Объект.ВладелецСправочника = ВыбранноеЗначение.Тип2;
	Модифицированность = Истина;
КонецПроцедуры

&НаКлиенте
Процедура КлассификаторНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	ПараметрыФормы = Новый Структура("Тип1,Тип2,ОграничениеТипа,ОграничениеТипаХранилище",
		"Хранилище",Объект.Классификатор,"Хранилище", ПолучитьСписокКлассификаторов()
	);
	ОткрытьФорму("Справочник.нсиВидыСправочников.Форма.ВыборТипа", ПараметрыФормы, Элемент);
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьСписокКлассификаторов()
	Запрос = Новый Запрос(
		"ВЫБРАТЬ
		|	нсиВидыСправочников.Ссылка
		|ИЗ
		|	Справочник.нсиВидыСправочников КАК нсиВидыСправочников
		|ГДЕ
		|	НЕ нсиВидыСправочников.ПометкаУдаления
		|	И нсиВидыСправочников.ВидСправочника = ЗНАЧЕНИЕ(Перечисление.нсиВидыСправочников.Классификатор)"
	);
	Результат = новый СписокЗначений;
	Результат.ЗагрузитьЗначения(Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Ссылка"));
	Возврат Результат;
КонецФункции 

&НаКлиенте
Процедура КлассификаторОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	Классификатор = нсиУниверсальноеХранилище.ПолучитьПредставлениеТипа(ВыбранноеЗначение.Тип1, ВыбранноеЗначение.Тип2);
	Объект.Классификатор = ВыбранноеЗначение.Тип2;
	Модифицированность = Истина;
КонецПроцедуры

&НаКлиенте
Процедура ТипНаименованияНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	ПараметрыФормы = Новый Структура("Тип1,Тип2,ОграничениеТипа", Объект.ТипНаименования, Неопределено, "Строка");
	ОткрытьФорму("Справочник.нсиВидыСправочников.Форма.ВыборТипа", ПараметрыФормы, Элемент);
КонецПроцедуры

&НаКлиенте
Процедура ТипНаименованияОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	Объект.ТипНаименования = нсиУниверсальноеХранилище.ПолучитьПредставлениеТипа(ВыбранноеЗначение.Тип1, ВыбранноеЗначение.Тип2);
	СтандартнаяОбработка = Ложь;
КонецПроцедуры

&НаКлиенте
Процедура ТипПолногоНаименованияНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	ПараметрыФормы = Новый Структура("Тип1,Тип2,ОграничениеТипа", Объект.ТипПолногоНаименования, Неопределено, "Строка");
	ОткрытьФорму("Справочник.нсиВидыСправочников.Форма.ВыборТипа", ПараметрыФормы, Элемент);
КонецПроцедуры

&НаКлиенте
Процедура ТипПолногоНаименованияОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	Объект.ТипПолногоНаименования = нсиУниверсальноеХранилище.ПолучитьПредставлениеТипа(ВыбранноеЗначение.Тип1, ВыбранноеЗначение.Тип2);
	СтандартнаяОбработка = Ложь;
КонецПроцедуры

&НаКлиенте
Процедура ИспользоватьКлассификациюПриИзменении(Элемент)
	Элементы.Классификатор.Доступность = Объект.ИспользоватьКлассификацию;
	УстановитьДоступность();
КонецПроцедуры

&НаКлиенте
Процедура ВидИерархииПриИзменении(Элемент)
	УстановитьДоступность();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ДобавитьТабличнуюЧасть(Команда)
	Если Объект.Ссылка.Пустая() Тогда
		Режим = РежимДиалогаВопрос.ДаНет;
		Оповещение = Новый ОписаниеОповещения("ЗаписатьЭлементСправочника", ЭтотОбъект);
		ПоказатьВопрос(Оповещение, "Вид справочника еще не записан. Записать?", Режим);	
	Иначе
		Оповещение = Новый ОписаниеОповещения("ДобавитьТабличнуюЧастьСервер", ЭтотОбъект);
		ОписаниеТипов = Новый ОписаниеТипов("Строка",,Новый КвалификаторыСтроки(100));
		ПоказатьВводЗначения(Оповещение,, "Введите имя табличной части.",ОписаниеТипов);
	КонецЕсли; 
КонецПроцедуры

&НаКлиенте
Процедура УдалитьТабличнуюЧасть(Команда)
	СтруктураПроверка = Новый Структура;
	СтруктураПроверка.Вставить("ТаблицаРеквизитов", NULL);
	ЗаполнитьЗначенияСвойств(СтруктураПроверка,ЭтотОбъект);
	Если СтруктураПроверка["ТаблицаРеквизитов"] = NULL Тогда
		Возврат;	
	КонецЕсли;

	ТекСтраница = Элементы.ГруппаТабличныеЧасти.ТекущаяСтраница;
	ТекТЧ = ТекСтраница.ПодчиненныеЭлементы[0].Имя;

	Отбор = Новый Структура("GUIDРеквизита",ТекТЧ);
	МассивПодчиненныхСправочников = ЭтотОбъект["ТаблицаРеквизитов"].НайтиСтроки(Отбор); 
	СпСсылка = МассивПодчиненныхСправочников[0].ВидСправочника;
	СписокТчДляУдаления = ЭтотОбъект["СписокТчДляУдаления"];
	
	Если СписокТчДляУдаления.НайтиПоЗначению(СпСсылка) = Неопределено Тогда
		СписокТчДляУдаления.Добавить(СпСсылка,ТекСтраница.Заголовок);
	    ТекСтраница.Заголовок = "(Удалено)";
	Иначе
		Страница = СписокТчДляУдаления.НайтиПоЗначению(СпСсылка);
		ТекСтраница.Заголовок = Страница.Представление;
		СписокТчДляУдаления.Удалить(Страница);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции


#Область ДинамическоеСозданиеЭлементовФормы

&НаСервере
Процедура СоздатьЭлементы(Ссылка = Неопределено)
	
	Запрос = Новый Запрос;
	ТекстЗапрос =  
	"ВЫБРАТЬ
	|	нсиВидыСправочников.Ссылка КАК Ссылка,
	|	нсиВидыСправочников.Ссылка.Наименование КАК НаименованиеСправочника,
	|	нсиВидыСправочников.Реквизиты.(
	|		Идентификатор,
	|		Наименование,
	|		ДляГруппы,
	|		Тип1,
	|		Тип2,
	|		Предопределенный,
	|		Имя,
	|		Подсказка,
	|		ТребоватьЗаполнения,
	|		Многострочный
	|	)
	|ИЗ
	|	Справочник.нсиВидыСправочников КАК нсиВидыСправочников
	|ГДЕ";
	Если Ссылка = Неопределено Тогда
		ТекстЗапрос = ТекстЗапрос+Символы.ПС+
		"	ВладелецСправочника = &Владелец
		|	И ВидСправочника = ЗНАЧЕНИЕ(Перечисление.нсиВидыСправочников.ТабличнаяЧасть)
		|	И НЕ ПометкаУдаления";
		Запрос.УстановитьПараметр("Владелец", Объект.Ссылка);	
	Иначе
		ТекстЗапрос = ТекстЗапрос+Символы.ПС+
		"	Ссылка = &Ссылка";
		Запрос.УстановитьПараметр("Ссылка", Ссылка);
	КонецЕсли;

	Запрос.Текст = ТекстЗапрос;

	РезультатЗапроса = Запрос.Выполнить();
	
	Если РезультатЗапроса.Пустой() Тогда
		Возврат;
	КонецЕсли;
	
	Если СоздатьТаблицуРеквизитов() Тогда
		ДобавитьРеквизитФормы("ТаблицаРеквизитов","ТаблицаЗначений");
		ДобавитьРеквизитФормы("ВидСправочника","СправочникСсылка.нсиВидыСправочников","ТаблицаРеквизитов");
		ДобавитьРеквизитФормы("GUIDРеквизита","Строка","ТаблицаРеквизитов");
		ДобавитьРеквизитФормы("СписокТчДляУдаления","СписокЗначений");
	КонецЕсли;
	
	ВыборкаВидСправочника = РезультатЗапроса.Выбрать();
	Пока ВыборкаВидСправочника.Следующий() Цикл
		Guid = Новый УникальныйИдентификатор;
		Guid = СтрЗаменить(Строка(Guid),"-","");
		ИмяСтраницы = "Стр_"+Guid;
		
		ЭлементСтраницаТч = Элементы.Добавить(ИмяСтраницы, Тип("ГруппаФормы"), Элементы["ГруппаТабличныеЧасти"]); 
		ЭлементСтраницаТч.Вид = ВидГруппыФормы.Страница;
		ЭлементСтраницаТч.Заголовок = ВыборкаВидСправочника.НаименованиеСправочника;				
		
		ИмяРеквизита = "ТаблицаЗначений_"+Guid;	
		ДобавитьРеквизитФормы(ИмяРеквизита,"ТаблицаЗначений",,,Истина);
		ДобавитьРеквизитыТЧ(ИмяРеквизита);
		
		ЭлементРеквизит = Элементы.Добавить(ИмяРеквизита, Тип("ТаблицаФормы"), ЭлементСтраницаТч);
		ЭлементРеквизит.ПутьКДанным = ИмяРеквизита;
		ЭлементРеквизит.УстановитьДействие("ПриАктивизацииСтроки",		"Подключаемый_ПриАктивизацииСтроки");
		ЭлементРеквизит.УстановитьДействие("ПриНачалеРедактирования",	"Подключаемый_ПриНачалеРедактирования");
		ЭлементРеквизит.УстановитьДействие("ОбработкаВыбора",			"Подключаемый_ОбработкаВыбора");
		ЭлементРеквизит.УстановитьДействие("ПослеУдаления",				"Подключаемый_ПослеУдаления");
		
		ДобавитьЭлементыТЧ(ИмяРеквизита);

		Стр = ЭтотОбъект["ТаблицаРеквизитов"].Добавить();
		Стр.ВидСправочника 	= ВыборкаВидСправочника.Ссылка;
		Стр.GUIDРеквизита 	= ИмяРеквизита;
		
		ВыборкаРеквизиты = ВыборкаВидСправочника.Реквизиты.Выбрать();
		Пока ВыборкаРеквизиты.Следующий() Цикл
			СтрокаТЧ = ЭтотОбъект[ИмяРеквизита].Добавить();
			ЗаполнитьЗначенияСвойств(СтрокаТЧ,ВыборкаРеквизиты);
			СтрокаТЧ.Тип = нсиУниверсальноеХранилище.ПолучитьПредставлениеТипа(ВыборкаРеквизиты.Тип1, ВыборкаРеквизиты.Тип2);
		КонецЦикла;

	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ДобавитьРеквизитФормы(Имя, пТип, Путь = Неопределено, Заголовок = "", СохраняемыеДанные = Ложь)
	
	Если ТипЗнч(пТип) = Тип("Строка") Тогда
		ТипыРеквизита = Новый Массив; 
		ТипыРеквизита.Добавить(Тип(пТип));
		ОписаниеТиповДляРеквизита = Новый ОписаниеТипов(ТипыРеквизита);
	Иначе
		ОписаниеТиповДляРеквизита = пТип;	
	КонецЕсли;
	
	НовыйРеквизит =	Новый РеквизитФормы(Имя,
				   ОписаниеТиповДляРеквизита,				// тип            
				   Путь,									// путь            
				   Заголовок,            					// заголовок            
				   СохраняемыеДанные);						// сохраняемые данные
				   
	ДобавляемыеРеквизиты = Новый Массив; 
	ДобавляемыеРеквизиты.Добавить(НовыйРеквизит); 
	ИзменитьРеквизиты(ДобавляемыеРеквизиты);
КонецПроцедуры 

&НаСервере
Процедура ДобавитьЭлементыТЧ(Родитель)
	
	// ГруппаРеквизитыОснование
	ИмяГруппы = "РеквизитыОсновные_"+Родитель;
	ЭлементГруппа = Элементы.Добавить(ИмяГруппы, Тип("ГруппаФормы"), Элементы[Родитель]);
	ЭлементГруппа.Вид = ВидГруппыФормы.ГруппаКолонок;
	ЭлементГруппа.Группировка = ГруппировкаКолонок.Вертикальная;
	
	// Наименование
	ДобавитьЭлементТЧ("Наименование",ЭлементГруппа,,Родитель,ВидПоляФормы.ПолеВвода);
	
	// Подсказка
	ДобавитьЭлементТЧ("Подсказка",ЭлементГруппа,,Родитель,ВидПоляФормы.ПолеВвода);
	
	// ГруппаРеквизитыОстальные
	ИмяГруппы = "РеквизитыОстальные_"+Родитель;
	ЭлементГруппа = Элементы.Добавить(ИмяГруппы, Тип("ГруппаФормы"), Элементы[Родитель]);
	ЭлементГруппа.Вид = ВидГруппыФормы.ГруппаКолонок;
	ЭлементГруппа.Группировка = ГруппировкаКолонок.Вертикальная;
	
	// Тип
	Обработчики = Новый Соответствие;
	Обработчики.Вставить("НачалоВыбора","Подключаемый_ТипНачалоВыбора");
	Обработчики.Вставить("ОбработкаВыбора","Подключаемый_ТипОбработкаВыбора");
	ДобавитьЭлементТЧ("Тип",ЭлементГруппа,,Родитель,ВидПоляФормы.ПолеВвода,Истина, Истина, Обработчики);
	
	// РеквизитыИнтерфейс
	ИмяГруппы = "РеквизитыИнтерфейс_"+Родитель;
	ЭлементГруппа = Элементы.Добавить(ИмяГруппы, Тип("ГруппаФормы"), ЭлементГруппа);
	ЭлементГруппа.Вид = ВидГруппыФормы.ГруппаКолонок;
	ЭлементГруппа.Группировка = ГруппировкаКолонок.Горизонтальная;
	
	// ДляГруппы
	Обработчики = Новый Соответствие;
	Обработчики.Вставить("ПриИзменении","Подключаемый_ДляГруппыПриИзменении");
	ДобавитьЭлементТЧ("ДляГруппы",ЭлементГруппа,"Для группы",Родитель,ВидПоляФормы.ПолеФлажка,,,Обработчики);
	
	// ТребоватьЗаполнения
	ДобавитьЭлементТЧ("ТребоватьЗаполнения",ЭлементГруппа,"Требовать заполнения",Родитель,ВидПоляФормы.ПолеФлажка);
	
	// Многострочный
	ДобавитьЭлементТЧ("Многострочный",ЭлементГруппа,,Родитель,ВидПоляФормы.ПолеФлажка);
	
КонецПроцедуры

&НаСервере
Процедура ДобавитьЭлементТЧ(Имя,Знач Родитель,пЗаголовок="", Знач Владелец, 
							Вид, КнопкаВыбора = Ложь, ВыбиратьТип = Ложь, Обработчики = Неопределено)
							
	Если ТипЗнч(Родитель) = Тип("Строка") Тогда
		Родитель = Элементы[Родитель];				
	КонецЕсли;
	ЭлементРеквизит = Элементы.Добавить(Владелец+Имя, Тип("ПолеФормы"), Родитель);
	ЭлементРеквизит.ПутьКДанным = Владелец+"."+Имя;
	ЭлементРеквизит.Заголовок = ?(пЗаголовок="",Имя,пЗаголовок);
	ЭлементРеквизит.Вид = Вид;
	Если КнопкаВыбора Тогда
		ЭлементРеквизит.КнопкаВыбора = Истина;
	КонецЕсли;
	Если ВыбиратьТип Тогда
		ЭлементРеквизит.ВыбиратьТип = Истина;
	КонецЕсли;
	Если Обработчики <> Неопределено Тогда
		Для Каждого Обработчик из Обработчики Цикл
			ЭлементРеквизит.УстановитьДействие(Обработчик.Ключ,Обработчик.Значение);
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ДобавитьРеквизитыТЧ(Владелец);
	
	ТипСтрока50 	= Новый ОписаниеТипов("Строка",,Новый КвалификаторыСтроки(50));
	ТипСтрока250	= Новый ОписаниеТипов("Строка",,Новый КвалификаторыСтроки(250));
	МассивТипов	= Новый Массив;
	МассивТипов.Добавить(Тип("Строка"));
	МассивТипов.Добавить(Тип("СправочникСсылка.нсиВидыСправочников"));
	ТипВидыСправочниковСтрока = Новый ОписаниеТипов(МассивТипов,,Новый КвалификаторыСтроки(50));
	
	ДобавитьРеквизитФормы("Идентификатор",			"УникальныйИдентификатор",							Владелец);
	ДобавитьРеквизитФормы("Наименование",			ТипСтрока50,										Владелец);	
	ДобавитьРеквизитФормы("ДляГруппы",				"Булево",											Владелец);
	ДобавитьРеквизитФормы("Тип",					"Строка",											Владелец);	
	ДобавитьРеквизитФормы("Тип1",					ТипСтрока50,										Владелец);	
	ДобавитьРеквизитФормы("Тип2",					ТипВидыСправочниковСтрока,							Владелец);	
	ДобавитьРеквизитФормы("Имя",					ТипСтрока50,										Владелец);	
	ДобавитьРеквизитФормы("Подсказка",				ТипСтрока250,										Владелец);	
	ДобавитьРеквизитФормы("ТребоватьЗаполнения",	"Булево",											Владелец);	
	ДобавитьРеквизитФормы("Многострочный",			"Булево",											Владелец);
	ДобавитьРеквизитФормы("ИндексКартинки",			"Число",											Владелец);

КонецПроцедуры

&НаКлиенте
Процедура ЗаписатьЭлементСправочника(Результат, Параметры) Экспорт
	Если Результат = КодВозвратаДиалога.Нет Тогда
		Возврат;
	КонецЕсли;
	Если ЭтотОбъект.Записать() Тогда
		Оповещение = Новый ОписаниеОповещения("ОбработкаВводаИмениТЧ", ЭтотОбъект);
		ОписаниеТипов = Новый ОписаниеТипов("Строка",,Новый КвалификаторыСтроки(100));
		ПоказатьВводЗначения(Оповещение,, "Введите имя табличной части.",ОписаниеТипов);	
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаВводаИмениТЧ(ВыбЗнач, Параметры) Экспорт
	ДобавитьТабличнуюЧастьСервер(ВыбЗнач, Параметры);
КонецПроцедуры

&НаСервере
Процедура ДобавитьТабличнуюЧастьСервер(ВыбЗнач, Параметры)
	Если ПустаяСтрока(ВыбЗнач) Тогда
		Возврат;	
	КонецЕсли;
	
	НовыйЭлемент = Справочники.нсиВидыСправочников.СоздатьЭлемент();
	НовыйЭлемент.Наименование 			= ВыбЗнач;
	НовыйЭлемент.ВладелецСправочника 	= Объект.Ссылка;
	НовыйЭлемент.ВидСправочника			= Перечисления.нсиВидыСправочников.ТабличнаяЧасть;
	НовыйЭлемент.ТипКода 				= "Строка(4)";
	Попытка
		НовыйЭлемент.Записать();
	Исключение
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не удалось создать метаданные ТЧ: "+ОписаниеОшибки());
	КонецПопытки;
	СоздатьЭлементы(НовыйЭлемент.Ссылка);
	
КонецПроцедуры

&НаСервере
Функция СоздатьТаблицуРеквизитов()
	СтруктураПроверка = Новый Структура;
	СтруктураПроверка.Вставить("ТаблицаРеквизитов", NULL);
	ЗаполнитьЗначенияСвойств(СтруктураПроверка,ЭтотОбъект);
	Возврат СтруктураПроверка["ТаблицаРеквизитов"] = NULL;
КонецФункции

&НаСервере
Процедура ЗаписатьПодчиненныеЭлементы(Отказ)
	Если СоздатьТаблицуРеквизитов() Тогда
		Возврат;
	КонецЕсли;
	
	СообщениеОбОшибке = "";
	СписокТчДляУдаления = ЭтотОбъект["СписокТчДляУдаления"];

	Для	Каждого ТЧ Из ЭтотОбъект["ТаблицаРеквизитов"] Цикл
		Если СписокТчДляУдаления.НайтиПоЗначению(ТЧ.ВидСправочника)<>Неопределено Тогда
			Продолжить;	
		КонецЕсли;
		спрОбъект = ТЧ.ВидСправочника.ПолучитьОбъект();
		РеквизитыОбъекта = спрОбъект.Реквизиты;
		РеквизитыОбъекта.Загрузить(ЭтотОбъект[ТЧ.GUIDРеквизита].Выгрузить());
		Если спрОбъект.ПроверитьЗаполнение() Тогда
			Попытка
				спрОбъект.Записать();
			Исключение
				СообщениеОбОшибке = СообщениеОбОшибке + ?(СообщениеОбОшибке="","",Символы.ПС)+"Не удалось записать метаданные """+ТЧ.ВидСправочника+"""!";	
			КонецПопытки;
		Иначе
			СообщениеОбОшибке = ?(СообщениеОбОшибке="","",", ")
				+"Не удалось записать структуру табличной части """+ТЧ.ВидСправочника+"""";	
		КонецЕсли;
	КонецЦикла;
	Для Каждого ТЧ Из СписокТчДляУдаления Цикл
		спрОбъект = ТЧ.Значение.ПолучитьОбъект();
		Попытка
			спрОбъект.УстановитьПометкуУдаления(Истина);
		Исключение
			СообщениеОбОшибке = СообщениеОбОшибке + ?(СообщениеОбОшибке="","",Символы.ПС)+"Не удалось пометить на удаление метаданные ТЧ """+Строка(ТЧ.Значение)+"""!";	
		КонецПопытки;
	КонецЦикла;
	
	Если Не ПустаяСтрока(СообщениеОбОшибке) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(СообщениеОбОшибке,,,,Отказ);
		СообщениеОбОшибке = ""; 
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти


&НаКлиенте 
Процедура ТипНачалоВыбора(Элемент, ИмяТч)
	ТекДанные = Элементы[ИмяТч].ТекущиеДанные;
	ПараметрыФормы = Новый Структура("Тип1,Тип2", ТекДанные.Тип1, ТекДанные.Тип2);
	ОткрытьФорму("Справочник.нсиВидыСправочников.Форма.ВыборТипа", ПараметрыФормы, Элемент);	
КонецПроцедуры

&НаКлиенте 
Процедура ТипОбработкаВыбора(ИмяТч, СтандартнаяОбработка, ВыбранноеЗначение)
	СтандартнаяОбработка = Ложь;
	ТекДанные = Элементы[ИмяТч].ТекущиеДанные;
	ТекДанные.Тип1 = ВыбранноеЗначение.Тип1;
	ТекДанные.Тип2 = ВыбранноеЗначение.Тип2;
	ТекДанные.Тип = нсиУниверсальноеХранилище.ПолучитьПредставлениеТипа(ВыбранноеЗначение.Тип1, ВыбранноеЗначение.Тип2);
	Модифицированность = Истина;
	МодифицированаСтруктура = Истина;
КонецПроцедуры

&НаКлиенте 
Процедура ПриНачалеРедактирования(Элемент, НоваяСтрока, Копирование, ИмяРеквизита)
	Если НоваяСтрока Тогда
		Если не Копирование Тогда
			Элемент.ТекущиеДанные.Наименование = ИмяРеквизита+Формат(Элемент.ТекущаяСтрока, "ЧГ=");
			Элемент.ТекущиеДанные.Тип1 = "Строка(50)";
			Элемент.ТекущиеДанные.Тип = нсиУниверсальноеХранилище.ПолучитьПредставлениеТипа(Элемент.ТекущиеДанные.Тип1, Элемент.ТекущиеДанные.Тип2);
		КонецЕсли;
		Элемент.ТекущиеДанные.Идентификатор = Новый УникальныйИдентификатор();
		МодифицированаСтруктура = Истина;
	КонецЕсли;	
КонецПроцедуры

&НаСервере 
Процедура УстановитьДоступность()
	
	Элементы.ТипВладельца.Доступность = Объект.ВидСправочника = Перечисления.нсиВидыСправочников.ТабличнаяЧасть;
		
	Элементы.ТипВладельца.АвтоОтметкаНезаполненного	= Элементы.ТипВладельца.Доступность;
	
	Элементы.Иерархический.Доступность = 
		Объект.ВидСправочника = Перечисления.нсиВидыСправочников.ФункциональныйСправочник
		ИЛИ Объект.ВидСправочника = Перечисления.нсиВидыСправочников.Классификатор;
	
	Элементы.ТипКода.Доступность = НЕ Объект.ВидСправочника = Перечисления.нсиВидыСправочников.ТабличнаяЧасть;
	Элементы.ТипНаименования.Доступность = НЕ Объект.ВидСправочника = Перечисления.нсиВидыСправочников.ТабличнаяЧасть;
	
	Элементы.ИспользоватьПолноеНаименование.Доступность = 
		Объект.ВидСправочника = Перечисления.нсиВидыСправочников.ФункциональныйСправочник;
	
	Элементы.ТипПолногоНаименования.Доступность = 
		Объект.ИспользоватьПолноеНаименование
		И Объект.ВидСправочника = Перечисления.нсиВидыСправочников.ФункциональныйСправочник;
		
	Элементы.ТипПолногоНаименования.АвтоОтметкаНезаполненного = Объект.ИспользоватьПолноеНаименование;
	Элементы.ТипПолногоНаименования.ОтметкаНезаполненного = 
		Объект.ИспользоватьПолноеНаименование 
		И НЕ ЗначениеЗаполнено(Объект.ТипПолногоНаименования);
		
	Элементы.РеквизитПредставления.Доступность = НЕ Объект.ВидСправочника = Перечисления.нсиВидыСправочников.ТабличнаяЧасть;
	Элементы.СтраницаТабличныеЧасти.Видимость = НЕ Объект.ВидСправочника = Перечисления.нсиВидыСправочников.ТабличнаяЧасть;
	Элементы.ПредставлениеОбъекта.Доступность = НЕ Объект.ВидСправочника = Перечисления.нсиВидыСправочников.ТабличнаяЧасть;
	Элементы.БыстрыйВыбор.Доступность = НЕ Объект.ВидСправочника = Перечисления.нсиВидыСправочников.ТабличнаяЧасть;
	Элементы.ОтборВФормеСписка.Доступность = НЕ Объект.ВидСправочника = Перечисления.нсиВидыСправочников.ТабличнаяЧасть;
	
	Элементы.ИспользоватьЗаявки.Доступность = 
		Объект.ВидСправочника = Перечисления.нсиВидыСправочников.ФункциональныйСправочник
		ИЛИ Объект.ВидСправочника = Перечисления.нсиВидыСправочников.Классификатор;
	Элементы.ИспользоватьНормализацию.Доступность = Объект.ВидСправочника = Перечисления.нсиВидыСправочников.ФункциональныйСправочник;
	Элементы.ИспользоватьКлассификацию.Доступность = Объект.ВидСправочника = Перечисления.нсиВидыСправочников.ФункциональныйСправочник;
	
	Если Объект.Иерархический И Объект.ВидИерархии = Перечисления.нсиВидыИерархииСправочников.ИерархияГруппИЭлементов Тогда
		Элементы.РеквизитыДляГруппы.Видимость = Истина;
	Иначе
		Элементы.РеквизитыДляГруппы.Видимость = Ложь;
	КонецЕсли;
	
	Элементы.ВидИерархии.Доступность = 
		Объект.Иерархический 
		И НЕ Объект.ВидСправочника = Перечисления.нсиВидыСправочников.ТабличнаяЧасть
		И НЕ Объект.ВидСправочника = Перечисления.нсиВидыСправочников.Классификатор;
		
	Элементы.ВидИерархии.АвтоОтметкаНезаполненного = Объект.Иерархический;
	Элементы.ВидИерархии.ОтметкаНезаполненного = Объект.Иерархический И НЕ ЗначениеЗаполнено(Объект.ВидИерархии);
		
	Элементы.Классификатор.Доступность = Объект.ИспользоватьКлассификацию;
	Элементы.Классификатор.АвтоОтметкаНезаполненного	= Объект.ИспользоватьКлассификацию;
	Элементы.Классификатор.ОтметкаНезаполненного = Объект.ИспользоватьКлассификацию И НЕ ЗначениеЗаполнено(Объект.Классификатор);
	
	Элементы.ИспользоватьДопКлассификацию.Доступность = Объект.ВидСправочника = Перечисления.нсиВидыСправочников.ФункциональныйСправочник;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаписатьИЗакрытьКлиент(Команда)
	ЗаписатьИЗакрыть(Истина);
КонецПроцедуры

&НаКлиенте
Процедура ЗаписатьКлиент(Команда)
	ЗаписатьИЗакрыть(Ложь);
КонецПроцедуры

&НаКлиенте
Процедура ЗаписатьИЗакрыть(Закрыть)
	Если МодифицированаСтруктура И нсиУниверсальноеХранилище.ЕстьДанные(Объект.Ссылка) Тогда
		ОписаниеОповещения = новый ОписаниеОповещения("ОбработкаОтветаНаВопросОРеструктуризации",ЭтаФорма,Закрыть);
		ПоказатьВопрос(
			ОписаниеОповещения,
			"Справочник содержит данные. Будет выполнена реструктуризация данных." "Продолжить запись?", 
			РежимДиалогаВопрос.ОкОтмена
		);
	Иначе
		Если Записать() Тогда
			МодифицированаСтруктура = Ложь;
			Если Закрыть Тогда 
				ЗадаватьВопросОСохраненииПриЗакрытии = Ложь;
				Закрыть();
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОтветаНаВопросОРеструктуризации(Результат,Закрыть) Экспорт
	Если Результат = КодВозвратаДиалога.Отмена Тогда
		ЗадаватьВопросОСохраненииПриЗакрытии = Истина;
		Возврат;
	Иначе
		Если Записать() Тогда 
			МодифицированаСтруктура = Ложь;
			Если Закрыть Тогда 
				ЗадаватьВопросОСохраненииПриЗакрытии = Ложь;
				Закрыть();
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОтветаСохранитьИзменения(Результат,ДП) Экспорт
	ЗадаватьВопросОСохраненииПриЗакрытии = Ложь;
	Если Результат = КодВозвратаДиалога.Да Тогда 
		ЗаписатьИЗакрыть(Истина);
	Иначе
		Закрыть();
	КонецЕсли;
КонецПроцедуры

#КонецОбласти





