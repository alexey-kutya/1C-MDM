Функция NewAttribute(СтрокаДанных) Экспорт 
	
	BrandGroupCode = СтрокаДанных.BrandGroupCode;
	
	Если СокрЛП(BrandGroupCode) = "" 
		ИЛИ СокрЛП(BrandGroupCode) = "NULL" Тогда
		Ответ = Новый Структура;
		Ответ.Вставить("error", "Не задан код группы бренда");
	Иначе
		BrandGroup = Справочники.GlobalBrand.НайтиПоКоду(BrandGroupCode);
		Если BrandGroup.Пустая() Тогда
			Ответ = Новый Структура;
			Ответ.Вставить("error", "Не найдена группа бренда по коду "+BrandGroupCode);
		Иначе
			Ответ = GlobEx.NewAttribute("GlobalBrand", Новый Структура("Код, Наименование, Родитель", СтрокаДанных.BrandCode, СтрокаДанных.BrandName, BrandGroup));
		КонецЕсли; 
	КонецЕсли; 
	
	Возврат Ответ;

КонецФункции

Функция NewGroupAttribute(СтрокаДанных) Экспорт 
	
	Возврат GlobEx.NewAttribute("GlobalBrand", Новый Структура("Код, Наименование", СтрокаДанных.BrandGroupCode, СтрокаДанных.BrandGroupName));

КонецФункции
