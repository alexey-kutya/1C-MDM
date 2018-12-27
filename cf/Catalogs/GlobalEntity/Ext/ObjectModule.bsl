
Процедура ПриЗаписи(Отказ)
	
	Если ЗначениеЗаполнено(Intercompany) Тогда
		Справочники.GlobalIntercompany.УстановитьСвязьМеждуEntityИIntercompany(Intercompany, Ссылка, "Entity");
	КонецЕсли; 
	
КонецПроцедуры
