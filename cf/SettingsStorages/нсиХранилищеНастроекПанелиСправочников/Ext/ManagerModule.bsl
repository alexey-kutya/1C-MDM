﻿
Процедура ОбработкаЗагрузки(КлючОбъекта, КлючНастроек, Настройки, ОписаниеНастроек, Пользователь)
	УстановитьПривилегированныйРежим(Истина);
	ПользовательИБ = ПользователиИнформационнойБазы.НайтиПоУникальномуИдентификатору(ПараметрыСеанса.ТекущийПользователь.ИдентификаторПользователяИБ);
	Настройки = ХранилищеНастроекДанныхФорм.Загрузить(КлючОбъекта,,,ПользовательИБ.Имя);
КонецПроцедуры

Процедура ОбработкаСохранения(КлючОбъекта, КлючНастроек, Настройки, ОписаниеНастроек, Пользователь)
	УстановитьПривилегированныйРежим(Истина);
	ПользовательИБ = ПользователиИнформационнойБазы.НайтиПоУникальномуИдентификатору(ПараметрыСеанса.ТекущийПользователь.ИдентификаторПользователяИБ);
	ХранилищеНастроекДанныхФорм.Сохранить(КлючОбъекта,,Настройки,,ПользовательИБ.Имя);
КонецПроцедуры
