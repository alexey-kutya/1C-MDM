﻿#Область ПрограммныйИнтерфейс

&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
	ПараметрыФормы = Новый Структура("ТипПозиции", 
		ПредопределенноеЗначение("Перечисление.нсиТипыПозицийСправочников.ЭталоннаяПозиция") );
	ОткрытьФорму("Справочник.нсиУслуги.ФормаСписка", 
		Новый Структура("Отбор", ПараметрыФормы), 
		ПараметрыВыполненияКоманды.Источник, 
		ПараметрыВыполненияКоманды.Уникальность, 
		ПараметрыВыполненияКоманды.Окно);
	
КонецПроцедуры

#КонецОбласти
