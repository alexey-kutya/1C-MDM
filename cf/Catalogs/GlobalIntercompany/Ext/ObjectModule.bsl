
Процедура ПриЗаписи(Отказ)
	
	Если ЗначениеЗаполнено(Entity) Тогда
		Справочники.GlobalIntercompany.УстановитьСвязьМеждуEntityИIntercompany(Entity, Ссылка, "Intercompany");
	КонецЕсли; 
	
КонецПроцедуры
