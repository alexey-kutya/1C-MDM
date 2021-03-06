﻿Процедура ВыполнитьРегистрациюДляAX(Ссылка) Экспорт 

	ПринадлежитAX = Метаданные.ПланыОбмена.Обмен_MDM_AX.Состав.Содержит(Ссылка.Метаданные());
	
	Если НЕ ПринадлежитAX Тогда
		Возврат;
	КонецЕсли;
	
	Если Ссылка.ЭтоГруппа Тогда
		Возврат;
	КонецЕсли;
	
	Узел = ПолучитьУзелОбменаAX();
	
	Если НЕ ЗначениеЗаполнено(Узел) Тогда
		Возврат;
	КонецЕсли;
	
	MDMСервер.interface(Ссылка).РегистрацияAX(Узел, Ссылка);
	
КонецПроцедуры
 
Функция ПолучитьУзелОбменаAX() Экспорт 

	ВыборкаУзлов = ПланыОбмена.Обмен_MDM_AX.Выбрать();
	
	Узел = ПланыОбмена.Обмен_MDM_AX.ПустаяСсылка();
	Пока ВыборкаУзлов.Следующий() Цикл
		Если НЕ ВыборкаУзлов.ЭтотУзел Тогда
			Узел = ВыборкаУзлов.Ссылка;
		КонецЕсли; 
	КонецЦикла;
	
	Возврат Узел;
	
КонецФункции // ПолучитьУзелОбмена()
