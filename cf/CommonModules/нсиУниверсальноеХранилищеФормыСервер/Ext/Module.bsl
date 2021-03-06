﻿
#Область ПрограммныйИнтерфейс

// Процедура создает реквизиты формы по структуре метаданных универсального хранилища.
//
// Параметры:
// Форма - УправляемаяФорма - форма элемента универсального справочника.
//
Процедура СоздатьРеквизиты(Форма) Экспорт
	РеквизитыФормы = Новый Массив;
	
	Если Форма.Объект.Свойство("пЭтоГруппа") Тогда 
		ЭтоГруппа = Форма.Объект.пЭтоГруппа;
	Иначе
		ЭтоГруппа = Ложь;
	КонецЕсли;
	
	ДобавитьРеквизит(РеквизитыФормы, "Наименование", Форма.пМетаданные.СтандартныеРеквизиты.Наименование, "");
	
	Если Форма.пМетаданные.СтандартныеРеквизиты.Свойство("ПолноеНаименование") И НЕ ЭтоГруппа Тогда 
		ДобавитьРеквизит(РеквизитыФормы, "ПолноеНаименование", Форма.пМетаданные.СтандартныеРеквизиты.ПолноеНаименование, "");
	КонецЕсли;
	
	Для каждого КлючИЗначение Из Форма.пМетаданные.Реквизиты Цикл
		Имя = КлючИЗначение.Ключ;
		пРеквизит = КлючИЗначение.Значение;
		Если (ЭтоГруппа и не пРеквизит.ДляГруппы) Тогда
			Продолжить;
		КонецЕсли;
		ДобавитьРеквизит(РеквизитыФормы, Имя, пРеквизит, "");
	КонецЦикла;
	
	
	Если не ЭтоГруппа Тогда
		ТипТЧ = Новый ОписаниеТипов("ТаблицаЗначений");
		Для каждого ТЧКлючИЗначение Из Форма.пМетаданные.ТабличныеЧасти Цикл
			Имя = ТЧКлючИЗначение.Ключ;
			пТЧ = ТЧКлючИЗначение.Значение;
			РеквизитыФормы.Добавить(Новый РеквизитФормы(Имя, ТипТЧ, "", пТЧ.Наименование, Истина));
			РеквизитыФормы.Добавить(Новый РеквизитФормы("пСсылка", Новый ОписаниеТипов("УникальныйИдентификатор"), Имя, ""));
			РеквизитыФормы.Добавить(Новый РеквизитФормы("Код", Новый ОписаниеТипов("Строка", , Новый КвалификаторыСтроки(4)), Имя, "N"));
			Для каждого КлючИЗначение Из пТЧ.Реквизиты Цикл
				ДобавитьРеквизит(РеквизитыФормы, КлючИЗначение.Ключ, КлючИЗначение.Значение, Имя);
			КонецЦикла;
		КонецЦикла;
	КонецЕсли;
	
	Форма.ИзменитьРеквизиты(РеквизитыФормы);
КонецПроцедуры

// Процедура создает элементы по структуре метаданных универсального хранилища в форме.
//
// Параметры:
// Форма - УправляемаяФорма - форма элемента универсального справочника.
//
Процедура СоздатьЭлементыФормы(Форма) Экспорт
	
	Если Форма.Объект.Свойство("пЭтоГруппа") Тогда 
		ЭтоГруппа = Форма.Объект.пЭтоГруппа;
	Иначе
		ЭтоГруппа = Ложь;
	КонецЕсли;
	
	Если НЕ Форма.пМетаданные.Иерархический Тогда
		Форма.Элементы.Родитель.Видимость = Ложь;
	Иначе
		Если Форма.пМетаданные.ВидИерархии = Перечисления.нсиВидыИерархииСправочников.ИерархияГруппИЭлементов Тогда 
			ПараметрыВыбора = Новый Массив;
			ПараметрыВыбора.Добавить(новый ПараметрВыбора("Отбор.ЭтоГруппа",Истина));
			ПараметрыВыбора.Добавить(новый ПараметрВыбора("Отбор.пЭтоГруппа",Истина));
			Форма.Элементы.Родитель.ПараметрыВыбора = Новый ФиксированныйМассив(ПараметрыВыбора);
		КонецЕсли;
	КонецЕсли;
	
	Если Форма.пМетаданные.СтандартныеРеквизиты.Свойство("Наименование") Тогда 
		ДобавитьЭлементФормы(Форма,"Наименование", Форма.пМетаданные.СтандартныеРеквизиты.Наименование, Форма.Элементы.ГруппаНаименование, "");
	КонецЕсли;
	
	Если Форма.пМетаданные.СтандартныеРеквизиты.Свойство("ПолноеНаименование") И НЕ ЭтоГруппа Тогда 
		ДобавитьЭлементФормы(Форма,"ПолноеНаименование", Форма.пМетаданные.СтандартныеРеквизиты.ПолноеНаименование, Форма.Элементы.ГруппаПолноеНаименование, "");
		Форма.Элементы.ПолноеНаименование.ПоложениеЗаголовка = ПоложениеЗаголовкаЭлементаФормы.Лево;
	КонецЕсли;
	
	Для каждого КлючИЗначение Из Форма.пМетаданные.Реквизиты Цикл
		Имя = КлючИЗначение.Ключ;
		пРеквизит = КлючИЗначение.Значение;
		Если ЭтоГруппа и не пРеквизит.ДляГруппы Тогда
			Продолжить;
		КонецЕсли;
		ДобавитьЭлементФормы(Форма,Имя, пРеквизит, Форма.Элементы.ГруппаРеквизиты, "");
	КонецЦикла;
	
	Если не ЭтоГруппа Тогда
		Для каждого ТЧКлючИЗначение Из Форма.пМетаданные.ТабличныеЧасти Цикл
			Имя = ТЧКлючИЗначение.Ключ;
			пТЧ = ТЧКлючИЗначение.Значение;
			Страница = Форма.Элементы.Добавить(
				ПолучитьУникальноеИмяЭлементаФормы(Форма,"Страница_"+Имя),
				Тип("ГруппаФормы"),
				Форма.Элементы.ГруппаСтраницы
			);
			Страница.Заголовок = пТЧ.Наименование;
			Таблица = Форма.Элементы.Добавить(
				ПолучитьУникальноеИмяЭлементаФормы(Форма,Имя),
				Тип("ТаблицаФормы"),
				Страница
			);
			Таблица.ПоложениеЗаголовка = ПоложениеЗаголовкаЭлементаФормы.Нет;
			Таблица.ПутьКДанным = Имя;
			Таблица.ИзменятьПорядокСтрок = Ложь;
			Таблица.Подсказка = пТЧ.Подсказка;
			ДобавитьКомандуТЧ(Форма, Имя, пТЧ, Таблица, "Подключаемый_СтрокуВверх", "Переместить вверх", БиблиотекаКартинок.ПереместитьВверх);
			ДобавитьКомандуТЧ(Форма, Имя, пТЧ, Таблица, "Подключаемый_СтрокуВниз", "Переместить вниз", БиблиотекаКартинок.ПереместитьВниз);
			Кнопка = ДобавитьКомандуТЧ(Форма, Имя, пТЧ, Таблица, "Подключаемый_СортироватьВозр", "Сортировать по возрастанию", БиблиотекаКартинок.СортироватьСписокПоВозрастанию);
			Кнопка.ТолькоВоВсехДействиях = Истина;
			Кнопка = ДобавитьКомандуТЧ(Форма,Имя, пТЧ, Таблица, "Подключаемый_СортироватьУбыв", "Сортировать по убыванию", БиблиотекаКартинок.СортироватьСписокПоУбыванию);
			Кнопка.ТолькоВоВсехДействиях = Истина;
			
			Таблица.УстановитьДействие("ПриНачалеРедактирования", "Подключаемый_ТаблицаПриНачалеРедактирования");
			Таблица.УстановитьДействие("ПриИзменении", "Подключаемый_ТаблицаПриИзменении");
			Таблица.УстановитьДействие("ПередУдалением", "Подключаемый_ТаблицаПередУдалением");
			
			Поле = Форма.Элементы.Добавить(
				ПолучитьУникальноеИмяЭлементаФормы(Форма,Имя+"Код"),
				Тип("ПолеФормы"),
				Таблица
			);
			Поле.ПутьКДанным = Имя+".Код";
			Поле.Вид = ВидПоляФормы.ПолеВвода;
			Поле.ГоризонтальноеПоложение = ГоризонтальноеПоложениеЭлемента.Право;
			Поле.ТолькоПросмотр = Истина;
			Поле.УстановитьДействие("ПриИзменении", "Подключаемый_ТаблицаРеквизитПростогоТипаПриИзменении");
			
			Для каждого КлючИЗначение Из пТЧ.Реквизиты Цикл
				ДобавитьЭлементФормы(Форма, КлючИЗначение.Ключ, КлючИЗначение.Значение, Таблица, Имя+".");
			КонецЦикла;
		КонецЦикла;
	КонецЕсли;
КонецПроцедуры

// Процедура заполняет реквизиты формы данными.
//
// Параметры:
// Форма   - УправляемаяФорма - форма элемента универсального справочника.
// пОбъект - Структура - данные элемента универсального справочника.
//
Процедура ЗаполнитьДанныеФормы(Форма,пОбъект) Экспорт
	Если пОбъект = Неопределено Тогда 
		Возврат;
	КонецЕсли;
	
	Если Форма.Объект.Свойство("пЭтоГруппа") Тогда 
		ЭтоГруппа = Форма.Объект.пЭтоГруппа;
	Иначе
		ЭтоГруппа = Ложь;
	КонецЕсли;
	
	ИменаТабличныхЧастей = "";
	Если НЕ ЭтоГруппа Тогда 
		Для каждого ТЧКлючИЗначение Из Форма.пМетаданные.ТабличныеЧасти Цикл
			Если не ПустаяСтрока(ИменаТабличныхЧастей) Тогда
				ИменаТабличныхЧастей = ИменаТабличныхЧастей+",";
			КонецЕсли;
			ИменаТабличныхЧастей = ИменаТабличныхЧастей+ТЧКлючИЗначение.Ключ;
		КонецЦикла;
	КонецЕсли;
	
	Если Форма.пМетаданные.СтандартныеРеквизиты.Свойство("Наименование") Тогда 
		Форма.Наименование = Форма.Объект.Наименование;
	КонецЕсли;
	
	Если Форма.пМетаданные.СтандартныеРеквизиты.Свойство("ПолноеНаименование")
		И НЕ ЭтоГруппа Тогда 
		Форма.ПолноеНаименование = Форма.Объект.ПолноеНаименование;
	КонецЕсли;
	
	ЗаполнитьЗначенияСвойств(Форма, пОбъект, , ИменаТабличныхЧастей);
	
	Если не ЭтоГруппа Тогда
		Для каждого пТЧ Из Форма.пМетаданные.ТабличныеЧасти Цикл
			ЗначениеВДанныеФормы(пОбъект[пТЧ.Ключ], Форма[пТЧ.Ключ]);
		КонецЦикла;
	КонецЕсли;
КонецПроцедуры

// Процедура формирует заголовок формы.
//
// Параметры:
// Форма - УправляемаяФорма - форма элемента универсального справочника.
//
Процедура СформироватьЗаголовок(Форма) Экспорт
	
	Если Форма.Объект.Свойство("пЭтоГруппа") Тогда 
		ЭтоГруппа = Форма.Объект.пЭтоГруппа;
	Иначе
		ЭтоГруппа = Ложь;
	КонецЕсли;
	
	ПредставлениеОбъекта = Форма.пМетаданные.ПредставлениеОбъекта;
	Если ПустаяСтрока(ПредставлениеОбъекта) Тогда
		ПредставлениеОбъекта = Форма.пМетаданные.Наименование;
	КонецЕсли;
	
	Если Форма.Объект.Ссылка.Пустая() Тогда
		Если ЭтоГруппа Тогда
			Форма.Заголовок = ПредставлениеОбъекта+" (создание группы)";
		Иначе
			Форма.Заголовок = ПредставлениеОбъекта+" (создание)";
		КонецЕсли;
	Иначе
		Форма.ПредставлениеЭлемента = Строка(Форма.Объект.Ссылка);
		Форма.Заголовок = ""+Форма.ПредставлениеЭлемента+" ("+ПредставлениеОбъекта+")";
	КонецЕсли;
КонецПроцедуры	

// Процедура - обработчик события ПриСозданииНаСервере формы элемента универсального справочника.
//
// Параметры:
// Форма - УправляемаяФорма - форма элемента универсального справочника.
//
Процедура ПриСозданииНаСервере(Форма) Экспорт
	
	Если Форма.пМетаданные = Неопределено Тогда 
		Форма.пМетаданные = нсиУниверсальноеХранилище.ПолучитьМетаданные(Форма.Объект.Владелец);
		СоздатьРеквизиты(Форма);
	КонецЕсли;
	
	Если не Форма.пМетаданные.ПраваДоступа.Просмотр Тогда
		ВызватьИсключение "Нет права на просмотр!";
	КонецЕсли;
	
	Если Форма.Объект.Ссылка.Пустая() И не Форма.пМетаданные.ПраваДоступа.Добавление Тогда
		ВызватьИсключение "Нет права на добавление!";
	КонецЕсли;
	
	ЭтоГруппа = Ложь;
	Если Форма.Объект.Ссылка.Метаданные().Реквизиты.Найти("пЭтоГруппа")<>Неопределено Тогда 
		ЭтоГруппа = Форма.Объект.пЭтоГруппа;
	КонецЕсли;
	
	Форма.КлючСохраненияПоложенияОкна = ?(ЭтоГруппа,"Группа","")+Форма.Объект.Владелец.УникальныйИдентификатор();
	
	Если Форма.Объект.Ссылка.Пустая() Тогда
		Форма.Объект.Владелец = Форма.пМетаданные.ВидСправочника;
		Если ЗначениеЗаполнено(Форма.Параметры.ЗначениеКопирования) Тогда
			пОбъект = нсиУниверсальноеХранилище.ПолучитьОбъект(Форма.пМетаданные, Форма.Параметры.ЗначениеКопирования);
			ЗаполнитьДанныеФормы(Форма,пОбъект);
		КонецЕсли;
	КонецЕсли;
	
	Если НЕ Форма.пМетаданные.Иерархический Тогда
		Форма.Объект.Родитель = Неопределено;
	Иначе
		Если Форма.пМетаданные.ВидИерархии = Перечисления.нсиВидыИерархииСправочников.ИерархияГруппИЭлементов
			И НЕ Форма.Объект.Родитель.пЭтоГруппа Тогда 
			
			Форма.Объект.Родитель = Неопределено;
		КонецЕсли;
	КонецЕсли;
	
	СоздатьЭлементыФормы(Форма);
	СформироватьЗаголовок(Форма);
	
	Форма.Элементы.Код.Маска = СформироватьМаску("X",Форма.пМетаданные.ДлинаКода);
	
	Если не Форма.пМетаданные.ПраваДоступа.Редактирование Тогда
		Форма.ТолькоПросмотр = Истина;
	КонецЕсли;
	
	Если не Форма.пМетаданные.ПраваДоступа.Добавление Тогда
		Форма.Элементы.ФормаСкопировать.Видимость = Ложь;
	КонецЕсли;
КонецПроцедуры

// Процедура устанавливает условное оформление списка формы списка универсального справочника.
//
// Параметры:
// УсловноеОформление - УсловноеОформлениеКомпоновкиДанных - объект условное оформление для заполнения.
// пМетаданные - Структура - структура метаданных универсального справоника.
//
Процедура УстановитьОформлениеСписка(УсловноеОформление, пМетаданные) Экспорт
	УсловноеОформление.Элементы.Очистить();
	
	Если пМетаданные.ИспользоватьЗаявки Тогда 
		НовыйЭлемент = УсловноеОформление.Элементы.Добавить();
		ЭлементОтбора = НовыйЭлемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
		ЭлементОтбора.ЛевоеЗначение = новый ПолеКомпоновкиДанных("СозданаЗаявка");
		ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
		ЭлементОтбора.ПравоеЗначение = Истина;
		ЭлементОтбора.Использование = Истина;
		НовыйЭлемент.Оформление.УстановитьЗначениеПараметра("ЦветТекста",Метаданные.ЭлементыСтиля.СозданаЗаявка.Значение);
		НовыйЭлемент.Представление = "Создана заявка";
		НовыйЭлемент.Использование = Истина;
	КонецЕсли;
	
	Если пМетаданные.ИспользоватьНормализацию Тогда 
		НовыйЭлемент = УсловноеОформление.Элементы.Добавить();
		ЭлементОтбора = НовыйЭлемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
		ЭлементОтбора.ЛевоеЗначение = новый ПолеКомпоновкиДанных("ОбработкаНачата");
		ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
		ЭлементОтбора.ПравоеЗначение = Истина;
		ЭлементОтбора.Использование = Истина;
		НовыйЭлемент.Оформление.УстановитьЗначениеПараметра("ЦветТекста",Метаданные.ЭлементыСтиля.ОбработкаНачата.Значение);
		НовыйЭлемент.Представление = "Обрабатывается";
		НовыйЭлемент.Использование = Истина;
	КонецЕсли;
	
	Если пМетаданные.ИспользоватьНормализацию ИЛИ пМетаданные.ИспользоватьЗаявки Тогда 
		НовыйЭлемент = УсловноеОформление.Элементы.Добавить();
		ЭлементОтбора = НовыйЭлемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
		ЭлементОтбора.ЛевоеЗначение = новый ПолеКомпоновкиДанных("Пользователь");
		ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
		ЭлементОтбора.ПравоеЗначение = ПараметрыСеанса.ТекущийПользователь;
		ЭлементОтбора.Использование = Истина;
		НовыйЭлемент.Оформление.УстановитьЗначениеПараметра("ЦветТекста",Метаданные.ЭлементыСтиля.ОбрабатываетсяПользователем.Значение);
		НовыйЭлемент.Представление = "Пользователь";
		НовыйЭлемент.Использование = Истина;
	КонецЕсли;
	
	Если пМетаданные.ИспользоватьЗаявки Тогда 
		НовыйЭлемент = УсловноеОформление.Элементы.Добавить();
		ЭлементОтбора = НовыйЭлемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
		ЭлементОтбора.ЛевоеЗначение = новый ПолеКомпоновкиДанных("ВременныйЭлемент");
		ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
		ЭлементОтбора.ПравоеЗначение = Истина;
		ЭлементОтбора.Использование = Истина;
		НовыйЭлемент.Оформление.УстановитьЗначениеПараметра("ЦветТекста",Метаданные.ЭлементыСтиля.ВременныйЭлемент.Значение);
		НовыйЭлемент.Представление = "Временный элемент";
		НовыйЭлемент.Использование = Истина;
	КонецЕсли;
	
КонецПроцедуры

// Процедура - обработчик события ПриЧтенииНаСервере формы элемента универсального справочника.
//
// Параметры:
// Форма - УправляемаяФорма - форма элемента универсального справочника.
//
Процедура ПриЧтенииНаСервере(Форма) Экспорт
	Если Форма.пМетаданные = Неопределено Тогда 
		Форма.пМетаданные = нсиУниверсальноеХранилище.ПолучитьМетаданные(Форма.Объект.Владелец);
		СоздатьРеквизиты(Форма);
	КонецЕсли;
	пОбъект = нсиУниверсальноеХранилище.ПолучитьОбъект(Форма.пМетаданные, Форма.Объект.Ссылка);
	ЗаполнитьДанныеФормы(Форма,пОбъект);
КонецПроцедуры

// Процедура - обработчик события ПередЗаписьюНаСервере формы элемента универсального справочника.
//
// Параметры:
// Форма         - УправляемаяФорма - форма элемента универсального справочника.
// ТекущийОбъект - СправочникОбъект.нсиКлассификаторУслуг, 
//				   СправочникОбъект.нсиУниверсальныйФункциональныйСправочник.
//
Процедура ПередЗаписьюНаСервере(Форма,ТекущийОбъект) Экспорт
	ТекущийОбъект.ДополнительныеСвойства.Вставить("Данные",Форма);
	ТекущийОбъект.ДополнительныеСвойства.Вставить("пМетаданные",Форма.пМетаданные);
КонецПроцедуры

// Процедура - обработчик события ОбработкаПроверкиЗаполнения формы элемента универсального справочника.
//
// Параметры:
// Форма - УправляемаяФорма - форма элемента универсального справочника.
// Отказ - Булево - признак ошибки при проверке заполнения.
//
Процедура ОбработкаПроверкиЗаполненияНаСервере(Форма, Отказ) Экспорт
	
	Если Форма.пМетаданные.Иерархический 
		И Форма.пМетаданные.ВидИерархии = Перечисления.нсиВидыИерархииСправочников.ИерархияГруппИЭлементов Тогда 
		Если ЗначениеЗаполнено(Форма.Объект.Родитель) И НЕ Форма.Объект.Родитель.пЭтоГруппа Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Родителем должна быть группа!",,"Объект.Родитель",,Отказ
			);
		КонецЕсли;
	КонецЕсли;
	
	ЭтоГруппа = Ложь;
	Если Форма.Объект.Ссылка.Метаданные().Реквизиты.Найти("пЭтоГруппа")<>Неопределено Тогда 
		ЭтоГруппа = Форма.Объект.пЭтоГруппа;
	КонецЕсли;
	
	Если НЕ Форма.Объект.ПометкаУдаления
		И(НЕ Форма.пМетаданные.ИспользоватьНормализацию
			ИЛИ (Форма.пМетаданные.ИспользоватьНормализацию 
			И Форма.Объект.ТипПозиции = Перечисления.нсиТипыПозицийСправочников.ЭталоннаяПозиция 
		)) Тогда 
		
		Если Форма.пМетаданные.ИспользоватьКлассификацию И НЕ ЗначениеЗаполнено(Форма.Объект.Класс)
			И НЕ ЭтоГруппа Тогда 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"Не заполнен класс!",,"Объект.Класс",,Отказ
				);
		КонецЕсли;
			
		Если Форма.пМетаданные.ИспользоватьПолноеНаименование И НЕ ЗначениеЗаполнено(Форма.Объект.ПолноеНаименование)
			И НЕ ЭтоГруппа Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Не заполнено полное наименование!",,"ПолноеНаименование",,Отказ
			);
		КонецЕсли;
		
		
		
		Для каждого КлючИЗначение Из Форма.пМетаданные.Реквизиты Цикл
			Имя = КлючИЗначение.Ключ;
			пРеквизит = КлючИЗначение.Значение;
			Если ЭтоГруппа и не пРеквизит.ДляГруппы Тогда
				Продолжить;
			КонецЕсли;
			Если пРеквизит.ТребоватьЗаполнения Тогда
				Если НЕ ЗначениеЗаполнено(Форма[Имя]) Тогда 
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
						"Не заполнен реквизит """+пРеквизит.Наименование+"""!",,Имя,,Отказ
					);
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
		
		Если Не ЭтоГруппа Тогда
			
			Для каждого ТЧКлючИЗначение Из Форма.пМетаданные.ТабличныеЧасти Цикл
				ИмяТЧ = ТЧКлючИЗначение.Ключ;
				ТЧ_ = ТЧКлючИЗначение.Значение;
				СписокПроверки = новый СписокЗначений;
				Для каждого КлючИЗначение Из ТЧ_.Реквизиты Цикл
					Если КлючИЗначение.Значение.ТребоватьЗаполнения Тогда
						СписокПроверки.Добавить(КлючИЗначение.Значение, КлючИЗначение.Ключ);
					КонецЕсли;
				КонецЦикла;
				Если СписокПроверки.Количество()=0 Тогда
					Продолжить;
				КонецЕсли;
				ДанныеТЧ = Форма[ИмяТЧ];
				Для каждого СтрокаТЧ Из ДанныеТЧ Цикл
					Для каждого ЭлементСписка Из СписокПроверки Цикл
						Если НЕ ЗначениеЗаполнено(СтрокаТЧ[ЭлементСписка.Представление]) Тогда 
							ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
								"Не заполнен реквизит """+ЭлементСписка.Значение.Наименование+""" в табличной части """+ТЧ_.Наименование+"""!",,
								ИмяТЧ+"["+Формат(ДанныеТЧ.Индекс(СтрокаТЧ), "ЧН=0; ЧГ=0")+"]."+ЭлементСписка.Представление,,
								Отказ
							);
						КонецЕсли;
					КонецЦикла;
				КонецЦикла;
			КонецЦикла;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

// Процедура - обработчик события ПриСозданииНаСервере формы списка универсального справочника.
//
// Параметры:
// Форма      - УправляемаяФорма - форма списка универсального справочника.
// Отказ      - Булево - признак отказа от создания формы.
// ДопПоля    - Строка - список дополниельных полей динамического списка, например:
//					"
//					|СтатусыОбработки.Пользователь КАК Пользователь,
//					|СтатусыОбработки.ВременныйЭлемент КАК ВременныйЭлемент, СтатусыОбработки.СозданаЗаявка КАК СозданаЗаявка,
//					|СтатусыОбработки.ОбработкаНачата КАК ОбработкаНачата, СтатусыОбработки.Обработано КАК Обработано,
//					|СтатусыОбработки.Обработавший КАК Обработавший".
//
// ДопСвязи   - Строка - текст запроса соединения со связами на языке запросов, например:
//					"
//					|ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.нсиСтатусыОбработкиСправочников КАК СтатусыОбработки...
//					|	ПО (СтатусыОбработки.Объект = ОсновнаяТаблица.Ссылка)...
//					|	// если список ссылок не пуст то отбор по нему...
//					|	И (ВЫБОР КОГДА &СсылкаНеОпределена ТОГДА ИСТИНА ИНАЧЕ ОсновнаяТаблица.Ссылка В (&Ссылка) КОНЕЦ)...
//					|	// не временные, или временные пользователя или временные по группе доступа...
//					|	И НЕ СтатусыОбработки.ВременныйЭлемент"...
//
// ДопУсловия - Строка - дополнительные условия на языке запросов для динамического списка, например: 
//					"И ОсновнаяТаблица.Ссылка = &Ссылка".
// ИмяСписка  - Строка - имя элемента списка формы.
//
Процедура ФормаСпискаПриСозданииНаСервере(Форма, Отказ, ДопПоля = "", ДопСвязи = "", ДопУсловия = "", ИмяСписка = "") Экспорт
	Попытка
		ВидСправочника = Форма.Параметры.Отбор.Владелец;
	Исключение
		Попытка
			ВидСправочника = Форма.ВидСправочника;
		Исключение
			ВидСправочника = Неопределено;
		КонецПопытки;
	КонецПопытки;
	
	Если НЕ ЗначениеЗаполнено(ВидСправочника) Тогда 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не устанвлен вид универсального справочника!",,,,Отказ);
		Возврат;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ИмяСписка) Тогда 
		ИмяСписка = "Список";
	КонецЕсли;
	
	Форма.КлючСохраненияПоложенияОкна = Строка(ВидСправочника.УникальныйИдентификатор());
	Форма.Параметры.ВидСправочника = ВидСправочника;
	Форма.пМетаданные = нсиУниверсальноеХранилище.ПолучитьМетаданные(ВидСправочника);
	
	Если не Форма.пМетаданные.ПраваДоступа.Просмотр Тогда
		ВызватьИсключение "Недостаточно прав для просмотра.";
	КонецЕсли;
	
	Форма.Заголовок = Форма.пМетаданные.Наименование;
	
	Форма[ИмяСписка].ТекстЗапроса = ПолучитьТекстЗапроса(Форма.пМетаданные,ДопПоля,ДопСвязи,ДопУсловия);
	
	Форма.Элементы[ИмяСписка].КартинкаСтрок = БиблиотекаКартинок.нсиПиктограммыЭлементов;
	Форма.Элементы[ИмяСписка].ПутьКДаннымКартинкиСтроки = ИмяСписка+".КартинкаСтроки";
	
	Форма[ИмяСписка].Параметры.УстановитьЗначениеПараметра("ВидСправочника", Форма.пМетаданные.ВидСправочника);
	Для каждого КлючИЗначение Из Форма.пМетаданные.Реквизиты Цикл
		Имя = КлючИЗначение.Ключ;
		пРеквизит = КлючИЗначение.Значение;
		
		пРеквизит = КлючИЗначение.Значение;
		Форма[ИмяСписка].Параметры.УстановитьЗначениеПараметра("Р"+Имя, пРеквизит.Идентификатор);
	КонецЦикла;
	
	Поле = Форма.Элементы.Добавить(
		ПолучитьУникальноеИмяЭлементаФормы(Форма,ИмяСписка+"Код"), 
		Тип("ПолеФормы"), 
		Форма.Элементы[ИмяСписка]
	);
	Поле.ПутьКДанным = ИмяСписка+".Код";
	
	Поле = Форма.Элементы.Добавить(
		ПолучитьУникальноеИмяЭлементаФормы(Форма,ИмяСписка+"Наименование"), 
		Тип("ПолеФормы"), 
		Форма.Элементы[ИмяСписка]
	);
	Поле.ПутьКДанным = ИмяСписка+".Наименование";
	
	Если Форма.пМетаданные.СтандартныеРеквизиты.Свойство("ПолноеНаименование") Тогда 
		Поле = Форма.Элементы.Добавить(
			ПолучитьУникальноеИмяЭлементаФормы(Форма,ИмяСписка+"ПолноеНаименование"),
			Тип("ПолеФормы"), 
			Форма.Элементы[ИмяСписка]
		);
		Поле.ПутьКДанным = ИмяСписка+".ПолноеНаименование";
	КонецЕсли;
	
	Для каждого КлючИЗначение Из Форма.пМетаданные.Реквизиты Цикл
		Имя = КлючИЗначение.Ключ;
		пРеквизит = КлючИЗначение.Значение;
		
		Поле = Форма.Элементы.Добавить(
			ПолучитьУникальноеИмяЭлементаФормы(Форма,ИмяСписка + Имя),
			Тип("ПолеФормы"), 
			Форма.Элементы[ИмяСписка]
		);
		
		Если пРеквизит.Тип.Тип1="Булево" Тогда
			Поле.Вид = ВидПоляФормы.ПолеФлажка;
		КонецЕсли;
		Поле.ПутьКДанным = ИмяСписка+"."+Имя;
		Поле.Заголовок = пРеквизит.Наименование;
	КонецЦикла;
	
	Если Форма.Элементы.Найти("ФормаСоздатьГруппу") <> Неопределено Тогда 
		Форма.Элементы.ФормаСоздатьГруппу.Видимость = 
		    Форма.пМетаданные.Иерархический 
			И Форма.пМетаданные.ВидИерархии = Перечисления.нсиВидыИерархииСправочников.ИерархияГруппИЭлементов;
	КонецЕсли;
	
	Если ВидСправочника.Иерархический Тогда
		Форма.Элементы[ИмяСписка].Отображение = ОтображениеТаблицы.ИерархическийСписок;
	Иначе
		Форма.Элементы[ИмяСписка].Отображение = ОтображениеТаблицы.Список;
	КонецЕсли;
	
	Если не Форма.пМетаданные.ПраваДоступа.Удаление Тогда
		УстановитьВидимостьКнопки(Форма,"ФормаУдалить",Ложь);
	КонецЕсли;
	
	Если не Форма.пМетаданные.ПраваДоступа.Добавление Тогда
		УстановитьВидимостьКнопки(Форма,"ФормаСоздать",Ложь);
		УстановитьВидимостьКнопки(Форма,ИмяСписка+"КонтекстноеМенюСоздать",Ложь);
		УстановитьВидимостьКнопки(Форма,"ФормаСкопировать",Ложь);
		УстановитьВидимостьКнопки(Форма,ИмяСписка+"КонтекстноеМенюСкопировать",Ложь);
		Если Форма.пМетаданные.Иерархический Тогда
			УстановитьВидимостьКнопки(Форма,"ФормаСоздатьГруппу",Ложь);
			УстановитьВидимостьКнопки(Форма,"ФормаСоздатьГруппу",Ложь);
		КонецЕсли;
	КонецЕсли;
	
	Если не Форма.пМетаданные.ПраваДоступа.ПометкаНаУдаление и не Форма.пМетаданные.ПраваДоступа.СнятиеПометкиНаУдаление Тогда
		УстановитьВидимостьКнопки(Форма,"ФормаУстановитьПометкуУдаления",Ложь);
		УстановитьВидимостьКнопки(Форма,ИмяСписка+"КонтекстноеМенюУстановитьПометкуУдаления",Ложь);
	КонецЕсли;
	
КонецПроцедуры

// Функция формирует запрос динамического списка универсального справочника.
//
// Параметры:
// пМетаданные - Структура - описание метданных универсального справочника.
// ДопПоля     - Строка - см. описанание ФормаСпискаПриСозданииНаСервере.
// ДопСвязи    - Строка - см. описанание ФормаСпискаПриСозданииНаСервере.
// ДопУсловия  - Строка - см. описанание ФормаСпискаПриСозданииНаСервере.
//
// Возвращаемое значение:
// Текст запроса - Строка.
//
Функция ПолучитьТекстЗапроса(пМетаданные, ДопПоля = "", ДопСвязи = "", ДопУсловия = "") Экспорт
	ТекстПоля = "";
	ТекстСвязи = "";
	
	ИмяРегистра = Неопределено;
	ИмяРесурса = Неопределено;
	
	ИмяОсновнойТаблицы = нсиУниверсальноеХранилищеПовтИсп.ПолучитьИмяСправочникаХранилища(пМетаданные.ВидСправочника);
	
	Для каждого КлючИЗначение Из пМетаданные.Реквизиты Цикл
		Имя = КлючИЗначение.Ключ;
		пРеквизит = КлючИЗначение.Значение;
		
		нсиУниверсальноеХранилище.ПолучитьИменаХранения(пРеквизит.Тип, ИмяРегистра, ИмяРесурса);
		
		ТекстСвязи = ТекстСвязи+"
		|ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений."+ИмяРегистра+" как Т"+Имя+"
		|	ПО Т"+Имя+".ВидСправочника = &ВидСправочника
		|		И Т"+Имя+".Элемент = ОсновнаяТаблица.Идентификатор
		|		И Т"+Имя+".Реквизит = &Р"+Имя;
		
		Оператор = нсиУниверсальноеХранилище.ПолучитьОператорВыражения(пРеквизит);
		Если ПустаяСтрока(Оператор) Тогда
			ТекстПоля = ТекстПоля+"
			|Т"+Имя+"."+ИмяРесурса+" КАК "+Имя+",";
		Иначе
			ТекстПоля = ТекстПоля+"
			|ВЫРАЗИТЬ(Т"+Имя+"."+ИмяРесурса+" КАК "+Оператор+") КАК "+Имя+",";
		КонецЕсли;
	КонецЦикла;
	
	Если пМетаданные.Иерархический Тогда
		ТекстПоля = ТекстПоля+"
		|ОсновнаяТаблица.Родитель КАК Родитель,";
	КонецЕсли;
	
	Если ИмяОсновнойТаблицы <> "нсиУниверсальныйКлассификатор" Тогда 
		ТекстПоля = ТекстПоля+"
		|ОсновнаяТаблица.пЭтоГруппа КАК ЭтоГруппа,";
	КонецЕсли;
	
	ТекстЗапроса = "
		|ВЫБРАТЬ
		|	ОсновнаяТаблица.Ссылка,
		|	ОсновнаяТаблица.Владелец КАК Владелец,
		|"+ТекстПоля+"
		|	ВЫРАЗИТЬ(ОсновнаяТаблица.Код КАК Строка("+пМетаданные.ДлинаКода+")) КАК Код,
		|	ОсновнаяТаблица.Наименование,";
	
	Если ИмяОсновнойТаблицы = "нсиУниверсальныйФункциональныйСправочник" Тогда 
		ТекстЗапроса = ТекстЗапроса + "
		|	ОсновнаяТаблица.Класс,
		|	ОсновнаяТаблица.ТипПозиции,
		|	ОсновнаяТаблица.ЭталоннаяПозиция,
		|	ОсновнаяТаблица.ЗаписьНеНормализуема,";
	КонецЕсли;
	
	Если пМетаданные.СтандартныеРеквизиты.Свойство("ПолноеНаименование") Тогда 
		ТекстЗапроса = ТекстЗапроса + "
		|	ОсновнаяТаблица.ПолноеНаименование,";
	КонецЕсли;
	
	ТекстЗапроса = ТекстЗапроса + "
	|	ОсновнаяТаблица.ПометкаУдаления КАК ПометкаУдаления,";
	
	Если пМетаданные.ВидИерархии = Перечисления.нсиВидыИерархииСправочников.ИерархияГруппИЭлементов Тогда 
		ТекстЗапроса = ТекстЗапроса + "
		|	ВЫБОР 
		|		КОГДА ОсновнаяТаблица.пЭтоГруппа ТОГДА 0 
		|		ИНАЧЕ 2 
		|	КОНЕЦ +";
	Иначе
		ТекстЗапроса = ТекстЗапроса + "
		|	2 +";
	КонецЕсли;
		
	ТекстЗапроса = ТекстЗапроса + "
	|	ВЫБОР 
	|		КОГДА ОсновнаяТаблица.ПометкаУдаления ТОГДА 1 
	|		ИНАЧЕ 0 
	|	КОНЕЦ КАК КартинкаСтроки"+?(ЗначениеЗаполнено(ДопПоля),",","")+"
	|	"+ДопПоля+"
	|ИЗ 
	|	Справочник."+ИмяОсновнойТаблицы+" КАК ОсновнаяТаблица"+?(ПустаяСтрока(ТекстСвязи),"",",")+"
	|	"+ТекстСвязи+"
	|	"+ДопСвязи+"
	|ГДЕ 
	|	ОсновнаяТаблица.Владелец = &ВидСправочника
	|	"+ДопУсловия+"
	|";
	Возврат ТекстЗапроса;	
КонецФункции

// Процедура устанавливает свойсто Видимость кнопки формы.
//
// Параметры:
// Форма     - УправляемаяФорма - форма списка универсального справочника.
// Имя       - Строка - имя формы.
// Видимость - Булево - значение свойства Видимость, которое надо установить.
//
Процедура УстановитьВидимостьКнопки(Форма,Имя,Видимость) Экспорт
	Если Форма.Элементы.Найти(Имя) <> Неопределено Тогда 
		Форма.Элементы[Имя].Видимость = Видимость;
	КонецЕсли;
КонецПроцедуры

// Функция формирует маску из символов Символ длиной Количество.
//
Функция СформироватьМаску(Символ,Количество) Экспорт
	Маска = "";
	Для Сч = 1 По Количество Цикл
		Маска = Маска + Символ;
	КонецЦикла;
	Возврат Маска;
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ДобавитьРеквизит(РеквизитыФормы, Имя, пРеквизит, Путь) 
	Если пРеквизит.Тип.Тип1  = "Хранилище" Тогда 
		ИмяСправочникаХранилища = нсиУниверсальноеХранилищеПовтИсп.ПолучитьИмяСправочникаХранилища(пРеквизит.Тип.Тип2); 
		РеквизитыФормы.Добавить(Новый РеквизитФормы(Имя, новый ОписаниеТипов("СправочникСсылка."+ИмяСправочникаХранилища), Путь, пРеквизит.Наименование, Истина));
	Иначе
		РеквизитыФормы.Добавить(Новый РеквизитФормы(Имя, пРеквизит.Тип1С, Путь, пРеквизит.Наименование, Истина));
	КонецЕсли;
КонецПроцедуры

Функция ПолучитьУникальноеИмяЭлементаФормы(Форма,ИсходноеИмя)
	ИмяЭлементаФормы = ИсходноеИмя;
	Счетчик = 1;
	Пока Форма.Элементы.Найти(ИмяЭлементаФормы)<>Неопределено Цикл
		ИмяЭлементаФормы = ИсходноеИмя + Формат(Счетчик,"ЧГ=0");
		Счетчик = Счетчик + 1;
	КонецЦикла;
	Возврат ИмяЭлементаФормы;
КонецФункции

Процедура ДобавитьЭлементФормы(Форма, Имя, пРеквизит, Родитель, Путь) 
	ПрефиксИмени = "";
	Если ТипЗнч(Родитель)<>Тип("УправляемаяФорма") И ТипЗнч(Родитель)<>Тип("ГруппаФормы") Тогда
		ПрефиксИмени = Родитель.Имя;
	КонецЕсли;
	
	Поле = Форма.Элементы.Добавить(
		ПолучитьУникальноеИмяЭлементаФормы(Форма,ПрефиксИмени+Имя),
		Тип("ПолеФормы"),
		Родитель
	);
	Поле.Подсказка = пРеквизит.Подсказка;
	
	Если пРеквизит.Тип.Тип1="Булево" Тогда
		Поле.Вид = ВидПоляФормы.ПолеФлажка;
		Поле.ПутьКДанным = Путь+Имя;
	ИначеЕсли пРеквизит.Тип.Тип1="Хранилище" Тогда
		Поле.Вид = ВидПоляФормы.ПолеВвода;
		Поле.ПутьКДанным = Путь+Имя;
		Поле.АвтоОтметкаНезаполненного = пРеквизит.ТребоватьЗаполнения;
		Поле.МногострочныйРежим = пРеквизит.Многострочный;
		Поле.БыстрыйВыбор = пРеквизит.Тип.БыстрыйВыбор;
		
		ПараметрыВыбора = Новый Массив;
		ПараметрыВыбора.Добавить(новый ПараметрВыбора("Отбор.Владелец",пРеквизит.Тип.Тип2));
		Поле.ПараметрыВыбора = новый ФиксированныйМассив(ПараметрыВыбора);
		
		Если не пРеквизит.Тип.ПравоПросмотр Тогда
			Поле.РедактированиеТекста = Ложь;
		КонецЕсли;
		
	Иначе
		Поле.Вид = ВидПоляФормы.ПолеВвода;
		Поле.ПутьКДанным = Путь+Имя;
		Поле.АвтоОтметкаНезаполненного = пРеквизит.ТребоватьЗаполнения;
		Поле.МногострочныйРежим = пРеквизит.Многострочный;
		Если пРеквизит.Многострочный Тогда 
			Поле.АвтоМаксимальнаяШирина = Ложь;
		КонецЕсли;
		Если пРеквизит.Тип.Свойство("БыстрыйВыбор") Тогда 
			Поле.БыстрыйВыбор = пРеквизит.Тип.БыстрыйВыбор;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

Функция ДобавитьКомандуТЧ(Форма, Имя, пТЧ, Таблица, ИмяКоманды, Заголовок, Картинка)
	Команда = Форма.Команды.Добавить(ИмяКоманды+Имя);
	Команда.Действие = ИмяКоманды;
	Команда.Заголовок = Заголовок;
	Команда.Картинка = Картинка;
	Команда.ИзменяетСохраняемыеДанные = Истина;
	
	Кнопка = Форма. Элементы.Добавить(Имя+ИмяКоманды, Тип("КнопкаФормы"), Таблица.КоманднаяПанель);
	Кнопка.ИмяКоманды = Команда.Имя;
	
	КнопкаМеню = Форма.Элементы.Добавить(Имя+"КонтекстноеМеню"+ИмяКоманды, Тип("КнопкаФормы"), Таблица.КонтекстноеМеню);
	КнопкаМеню.ИмяКоманды = Команда.Имя;
	Возврат Кнопка;
КонецФункции

#КонецОбласти