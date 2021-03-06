﻿#Область ПрограммныйИнтерфейс

&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
	ПараметрыФормы = Новый Структура("Организация", ПолучитьОгранизацию(ПараметрКоманды));
	
	ОткрытьФорму("Справочник.нсиДоговорыСПокупателями.ФормаСписка", 
		Новый Структура("Отбор", ПараметрыФормы), 
		ПараметрыВыполненияКоманды.Источник, 
		ПараметрыВыполненияКоманды.Уникальность, 
		ПараметрыВыполненияКоманды.Окно);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ПолучитьОгранизацию(Контрагент)
	
	УстановитьПривилегированныйРежим(Истина);
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Организации.Ссылка
		|ИЗ
		|	Справочник.Организации КАК Организации
		|ГДЕ
		|	Организации.Контрагент = &Контрагент";

	Запрос.УстановитьПараметр("Контрагент", Контрагент);

	Результат = Запрос.Выполнить();

	ВыборкаДетальныеЗаписи = Результат.Выбрать();

	Организация = Неопределено;
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Организация = ВыборкаДетальныеЗаписи.Ссылка;
	КонецЦикла;

	УстановитьПривилегированныйРежим(Ложь);
	
	Возврат Организация;
	
КонецФункции	


#КонецОбласти
