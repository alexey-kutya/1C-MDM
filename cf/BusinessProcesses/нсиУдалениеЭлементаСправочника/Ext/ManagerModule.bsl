﻿#Область СлужебныеПроцедурыИФункции

// Получить структуру с описанием формы выполнения задачи.
// Вызывается при открытии формы выполнения задачи.
//
// Параметры
//   ЗадачаСсылка  – ЗадачаСсылка.ЗадачаИсполнителя – задача 
//   ТочкаМаршрутаСсылка – точка маршрута 
//
// Возвращаемое значение:
//   Структура   – структуру с описанием формы выполнения задачи.
//                 Ключ "ИмяФормы" содержит имя формы, передаваемое в метод контекста ОткрытьФорму(). 
//                 Ключ "ПараметрыФормы" содержит параметры формы. 
//
Функция ФормаВыполненияЗадачи(ЗадачаСсылка, ТочкаМаршрутаБизнесПроцесса) Экспорт
	
	Результат = Новый Структура;
	Результат.Вставить("ПараметрыФормы", Новый Структура("Ключ", ЗадачаСсылка));
	Результат.Вставить("ИмяФормы", "БизнесПроцесс.нсиУдалениеЭлементаСправочника.Форма.Действие" + 
		ТочкаМаршрутаБизнесПроцесса.Имя);
	Возврат Результат;
	
КонецФункции

// Вызывается при выполнении задачи из формы списка.
//
// Параметры
//   ЗадачаСсылка  – ЗадачаСсылка.ЗадачаИсполнителя – задача 
//   ТочкаМаршрутаСсылка – точка маршрута 
//
Процедура ОбработкаВыполненияПоУмолчанию(ЗадачаСсылка, БизнесПроцессСсылка, ТочкаМаршрутаБизнесПроцесса) Экспорт
	
	// устанавливаем значения по умолчанию для пакетного выполнения задач
	
	ЗаданиеОбъект = БизнесПроцессСсылка.ПолучитьОбъект();
	ЗаблокироватьДанныеДляРедактирования(ЗаданиеОбъект.Ссылка);
	ЗаданиеОбъект.Выполнено = Истина;	
	
	Если ТочкаМаршрутаБизнесПроцесса = ТочкиМаршрута.ПроверитьВозможностьУдаления Тогда
		ЗаданиеОбъект.Исполнитель = ПользователиКлиентСервер.ТекущийПользователь();
		ЗаданиеОбъект.Методолог = ПользователиКлиентСервер.ТекущийПользователь();
		ЗаданиеОбъект.ВывестиИзОбращения = Истина;
	КонецЕсли;
	
	ЗаданиеОбъект.Записать();
	
КонецПроцедуры	

Функция ПолучитьШаги() Экспорт
	Шаги = Новый Массив;
	Шаги.Добавить(Перечисления.нсиШагиБП.Обработка);
	Возврат Шаги;
КонецФункции

#КонецОбласти