﻿
#Область ПрограммныйИнтерфейс

// Возвращает имя справочника по виду справочника
//
Функция ПолучитьИмяСправочникаХранилища(ВидСправочника) Экспорт
	
	Если Не ЗначениеЗаполнено(ВидСправочника) Тогда
		ВызватьИсключение "Не определён вид справочника!";
	КонецЕсли;
	
	Если ВидСправочника.ВидСправочника = Перечисления.нсиВидыСправочников.ФункциональныйСправочник Тогда 
		Возврат "нсиУниверсальныйФункциональныйСправочник";
	ИначеЕсли ВидСправочника.ВидСправочника = Перечисления.нсиВидыСправочников.Классификатор Тогда 
		Возврат "нсиУниверсальныйКлассификатор";
	Иначе
		ВызватьИсключение "Для вида справочника """+ВидСправочника.ВидСправочника+""" не определено имя справочника-хранилища!";
	КонецЕсли;
		
КонецФункции

#КонецОбласти
