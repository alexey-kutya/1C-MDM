//SYNC Global SQL
Процедура Exchange_MDM_Global() Экспорт
	
	Для каждого globalEntity Из GlobalEntities() Цикл
		ВыполнитьСинхронизациюGlobal(globalEntity.Значение);
	КонецЦикла; 
	
КонецПроцедуры

//основной блок

Функция СинхронизацияGlobal(dataKey, interactiveMode) Экспорт 
	
	Синхронизирован = Ложь;
	
	globalEntity = GlobalEntities(dataKey)[dataKey];
	
	Если globalEntity.Свойство("error") Тогда
		Если interactiveMode Тогда
			Сообщить("Неизвестный ключ данных "+dataKey);
		Иначе
		КонецЕсли; 
	Иначе
		Синхронизирован = ВыполнитьСинхронизациюGlobal(globalEntity, interactiveMode);
	КонецЕсли; 
	
	Возврат Синхронизирован;
	
КонецФункции

Функция ВыполнитьСинхронизациюGlobal(entity, interactiveMode = Ложь) 

	Выполнять = Ложь;
	entity.Свойство("Выполнять", Выполнять);
	
	Если НЕ Выполнять Тогда
		Возврат Ложь;
	КонецЕсли; 
	
	objectInterface = Справочники[entity.Ключ];
	
	mainTable = entity.MainTableName;
	responseTable = entity.ResponseTableName;

	сonnectionParameters = ConnectionParameters();
	
	//Читаем таблицу ответов Global
	readResult = dbRead(OpenConnectionADODB(сonnectionParameters), interactiveMode, responseTable, Новый Массив()); //чтение
	
	readError = Неопределено;
	ТаблицаОтветов = Неопределено;
	
	Если readResult.Свойство("result", ТаблицаОтветов) Тогда
		
		//Обрабатываем ответы Global
		РезультатОбработки = ОбработатьОтветыGlobalMDM(objectInterface, ТаблицаОтветов, interactiveMode);
		
		//по результатам обработки вносим изменения в таблицы обмена SQL
		Для каждого ОтветСтрока Из РезультатОбработки.ОбработанныеОтветы Цикл
			
			Confirmed = Число(ОтветСтрока.Confirmed);
			
			ArrayGUID = Новый Массив();
			ArrayGUID.Добавить(ОтветСтрока.GUID);
			
			Если Confirmed = 0 Тогда //reject
				dbDelete(OpenConnectionADODB(сonnectionParameters), interactiveMode, mainTable, ArrayGUID);
				dbDelete(OpenConnectionADODB(сonnectionParameters), interactiveMode, responseTable, ArrayGUID);
			ИначеЕсли Confirmed = 1 Тогда //accept
				DataSet = Новый Структура;
				DataSet.Вставить("Confirmed", "1");
				
				Для каждого ИдентификаторGlobal Из objectInterface.ИдентификаторыGlobal() Цикл
					DataSet.Вставить(ИдентификаторGlobal.Ключ, ОтветСтрока[ИдентификаторGlobal.Ключ]);
				КонецЦикла;
				
				Если НЕ РезультатОбработки.АтрибутыGlobalЗначения = Неопределено Тогда
					ПоляАтрибутовDataSet = objectInterface.ПоляАтрибутовDataSet();
					ЧисловыеПоляDataSet = objectInterface.ЧисловыеПоляDataSet();
					
					Для каждого Атрибут Из РезультатОбработки.АтрибутыGlobalЗначения Цикл
						Для каждого ПолеАтрибута Из ПоляАтрибутовDataSet[Атрибут.Ключ] Цикл
							ИмяПоля = ПолеАтрибута.Ключ; 
							ЗначениеПоля = ОтветСтрока[ПолеАтрибута.Ключ];
							DataSet.Вставить(ИмяПоля, ?(ЧисловыеПоляDataSet.Свойство(ИмяПоля), ФорматироватьЧисло(ЗначениеПоля), ЗначениеПоля));
						КонецЦикла;
					КонецЦикла; 
				КонецЕсли; 
				dbUpdate(OpenConnectionADODB(сonnectionParameters), interactiveMode, mainTable, ArrayGUID, DataSet);
				dbDelete(OpenConnectionADODB(сonnectionParameters), interactiveMode, responseTable, ArrayGUID);
			ИначеЕсли Confirmed = 2 Тогда //to correction
				dbDelete(OpenConnectionADODB(сonnectionParameters), interactiveMode, responseTable, ArrayGUID);
			КонецЕсли; 
		КонецЦикла; 
		
	ИначеЕсли readResult.Свойство("error", readError) Тогда
		ОтправитьУведомление(readError, УровеньЖурналаРегистрации.Ошибка, InteractiveMode);
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции // ВыполнитьСинхронизациюНаСервере()

Функция ОбработатьОтветыGlobalMDM(objectInterface, ТаблицаОтветов, InteractiveMode)

	TimeStamp = ТекущаяДата();
	ТаблицаРезультат = ТаблицаОтветов.Скопировать();
	States = Новый Массив();
	States.Добавить(Перечисления.States.Rejected);
	States.Добавить(Перечисления.States.Approved);
	States.Добавить(Перечисления.States.ToCorrection);
	
	Для каждого ОтветСтрока Из ТаблицаОтветов Цикл
		СсылкаGlobal = objectInterface.ПолучитьСсылку(Новый УникальныйИдентификатор(ОтветСтрока.GUID));
		СсылкаLocal = СсылкаGlobal.LocalEntity;
		GlobalID_0 = СсылкаGlobal.GlobalID;
		Если ОбщегоНазначения.СсылкаСуществует(СсылкаGlobal) Тогда
			Confirmed = Число(ОтветСтрока.Confirmed);
			ОбъектGlobal = СсылкаGlobal.ПолучитьОбъект();
			Если Confirmed >= 0 И Confirmed <= 2 Тогда
				ОбъектGlobal.State = States[Confirmed];
				ОбъектGlobal.TimeStamp = TimeStamp;
				ОбъектGlobal.Comment = ОтветСтрока.Comment;
				ОбъектGlobal.CollisionMessage = "";
				
				Если Confirmed = 1 Тогда //approved
					error = Неопределено;
					// 1
					РезультатПроверкиОтвета = objectInterface.ВыполнитьПроверкуОтвета(ОтветСтрока);
					Если РезультатПроверкиОтвета.Свойство("result") Тогда
						
						АтрибутыGlobal = objectInterface.АтрибутыGlobal();
						АтрибутыGlobalЗначения = Неопределено;
						
						Если АтрибутыGlobal.Количество() Тогда
							// 2
							АтрибутыGlobalЗначения = НайтиАтрибутыGlobal(ОтветСтрока, АтрибутыGlobal, objectInterface.ПоляКодовОтветаGlobal());
							// 3                                                                                                                                
							СравнениеАтрибутовLocalРезультат = ПроверитьСоответствиеАтрибутовLocal(СсылкаLocal, АтрибутыGlobalЗначения, objectInterface.ПолучитьСоответствияАтрибутовLocal(АтрибутыGlobalЗначения));
							
							Если СравнениеАтрибутовLocalРезультат.Свойство("result") Тогда
								arguments = Новый Структура;
								arguments.Вставить("ОтветСтрока", ОтветСтрока);
								arguments.Вставить("СсылкаGlobal", СсылкаGlobal);
								// 4
								СозданиеАтрибутовGlobalРезультат = СоздатьАтрибутыGlobal(ОтветСтрока, АтрибутыGlobalЗначения, АтрибутыGlobal, InteractiveMode);
								Если СозданиеАтрибутовGlobalРезультат.Свойство("result")  Тогда
									// 5
									УстановкаСоответствияРезультат = УстановитьСоответствиеАтрибутовGlobalLocal(АтрибутыGlobalЗначения, СсылкаLocal, objectInterface.СоответствияGlobalLocal(), InteractiveMode);
									Если УстановкаСоответствияРезультат.Свойство("result")  Тогда
										// 6
										ЗаполнитьЗначенияСвойств(ОбъектGlobal, АтрибутыGlobalЗначения);
									ИначеЕсли УстановкаСоответствияРезультат.Свойство("error", error)  Тогда
										ОбработкаКоллизии(ТаблицаРезультат, ОбъектGlobal, error, ОтветСтрока, InteractiveMode);
									КонецЕсли; 
								ИначеЕсли СозданиеАтрибутовGlobalРезультат.Свойство("error", error)  Тогда
									ОбработкаКоллизии(ТаблицаРезультат, ОбъектGlobal, error, ОтветСтрока, InteractiveMode);
								КонецЕсли; 
							ИначеЕсли СравнениеАтрибутовLocalРезультат.Свойство("error", error) Тогда
								ОбработкаКоллизии(ТаблицаРезультат, ОбъектGlobal, error, ОтветСтрока, InteractiveMode);
							КонецЕсли; 
						КонецЕсли; 
					ИначеЕсли РезультатПроверкиОтвета.Свойство("error", error) Тогда
						ОбработкаКоллизии(ТаблицаРезультат, ОбъектGlobal, error, ОтветСтрока, InteractiveMode);
					КонецЕсли; 
					
				КонецЕсли;
			Иначе
				СообщениеОбОшибке = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку("ru = 'Неожиданное значение Confirmed %1'; en = 'Unexpected Confirmed value %1'", Строка(ОтветСтрока.Confirmed));
				ОбъектGlobal.State = Перечисления.States.Collision;
				ОбъектGlobal.CollisionMessage = СообщениеОбОшибке;
				ОтправитьУведомление(НСтр(СообщениеОбОшибке, "ru"), УровеньЖурналаРегистрации.Ошибка, InteractiveMode);
				ОтправитьУведомление(НСтр(СообщениеОбОшибке, "en"), УровеньЖурналаРегистрации.Ошибка, InteractiveMode);
				
				СтрокаGUID = ТаблицаРезультат.Найти(ОтветСтрока.GUID, "GUID"); 
				Если НЕ СтрокаGUID = Неопределено Тогда
					ТаблицаРезультат.Удалить(СтрокаGUID);
				КонецЕсли; 
			КонецЕсли;
			
			Попытка
				Если ОбъектGlobal.State = Перечисления.States.Approved Тогда
					
					Для каждого ИдентификаторGlobal Из objectInterface.ИдентификаторыGlobal() Цикл
						ОбъектGlobal[ИдентификаторGlobal.Значение] = ОтветСтрока[ИдентификаторGlobal.Ключ];
					КонецЦикла;
						
					Если СтрНайти(СсылкаLocal.GlobalIDs, ОбъектGlobal.GlobalID) = 0 Тогда
						ОбъектLocal = СсылкаLocal.ПолучитьОбъект();
						Если ПустаяСтрока(ОбъектLocal.GlobalIDs) Тогда
							ОбъектLocal.GlobalIDs = ОбъектGlobal.GlobalID;
						Иначе
							ОбъектLocal.GlobalIDs = ?(СтрНайти(ОбъектLocal.GlobalIDs, GlobalID_0) > 0, СтрЗаменить(ОбъектLocal.GlobalIDs,GlobalID_0,ОбъектGlobal.GlobalID),ОбъектLocal.GlobalIDs+"; "+ОбъектGlobal.GlobalID);
						КонецЕсли; 

						ОбъектLocal.Записать();
					КонецЕсли; 
					ПланыОбмена.Обмен_МДМ_УПП.ВыполнитьРегистрациюДляУПП(СсылкаLocal);
				КонецЕсли; 
				ОбъектGlobal.Записать();
			Исключение
				ОтправитьУведомление(ОписаниеОшибки(), УровеньЖурналаРегистрации.Ошибка, InteractiveMode);
				СтрокаGUID = ТаблицаРезультат.Найти(ОтветСтрока.GUID, "GUID"); 
				Если НЕ СтрокаGUID = Неопределено Тогда
					ТаблицаРезультат.Удалить(СтрокаGUID);
				КонецЕсли; 
			КонецПопытки;
			
		Иначе
			СообщениеОбОшибке = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку("ru = 'Не найден элемент справочника по GUID %1'; en = 'No matching GUID %1'", Строка(ОтветСтрока.GUID));
			ОтправитьУведомление(НСтр(СообщениеОбОшибке, "ru"), УровеньЖурналаРегистрации.Ошибка, InteractiveMode);
			ОтправитьУведомление(НСтр(СообщениеОбОшибке, "en"), УровеньЖурналаРегистрации.Ошибка, InteractiveMode);
			СтрокаGUID = ТаблицаРезультат.Найти(ОтветСтрока.GUID, "GUID"); 
			Если НЕ СтрокаGUID = Неопределено Тогда
				ТаблицаРезультат.Удалить(СтрокаGUID);
			КонецЕсли; 
		КонецЕсли; 
	КонецЦикла;
	
	Возврат Новый Структура("ОбработанныеОтветы, АтрибутыGlobalЗначения", ТаблицаРезультат, АтрибутыGlobalЗначения);

КонецФункции // ОбработатьОтветыGlobalMDM()

Процедура ОбработкаКоллизии(ТаблицаРезультат, ОбъектGlobal, errorMessage, ОтветСтрока, InteractiveMode)
	
	ОтправитьУведомление(errorMessage, УровеньЖурналаРегистрации.Ошибка, InteractiveMode);
	ОбъектGlobal.State = Перечисления.States.Collision;
	ОбъектGlobal.CollisionMessage = errorMessage;
	СтрокаGUID = ТаблицаРезультат.Найти(ОтветСтрока.GUID, "GUID"); 
	Если НЕ СтрокаGUID = Неопределено Тогда
		ТаблицаРезультат.Удалить(СтрокаGUID);
	КонецЕсли; 
	
КонецПроцедуры // ОбработкаКоллизии()
 
Функция ПроверитьСоответствиеАтрибутовLocal(СсылкаLocal, АтрибутыGlobal, СоответствияАтрибутовРезультатыЗапроса)
	
	АтрибутыНесоответствия = Новый Массив;
	Для каждого РезультатЗапроса Из СоответствияАтрибутовРезультатыЗапроса Цикл
		
		Отбор = Новый Структура;
		Для каждого Колонка Из РезультатЗапроса.Колонки Цикл
			ИмяАтрибута = Колонка.Имя;
			Отбор.Вставить(ИмяАтрибута, СсылкаLocal[ИмяАтрибута]);
		КонецЦикла;
		ТаблицаАтрибутLocal = РезультатЗапроса.Выгрузить();
		СтрокиСоответствия = ТаблицаАтрибутLocal.НайтиСтроки(Отбор);
		Если НЕ СтрокиСоответствия.Количество() Тогда
			Для каждого СтрокаТаблицы Из ТаблицаАтрибутLocal Цикл
			    Для каждого Колонка Из РезультатЗапроса.Колонки Цикл
					ИмяАтрибута = Колонка.Имя;
					Если НЕ СсылкаLocal[ИмяАтрибута] = СтрокаТаблицы[ИмяАтрибута] Тогда
						АтрибутыНесоответствия.Добавить(ИмяАтрибута);
					КонецЕсли; 
				КонецЦикла; 
			КонецЦикла; 
		КонецЕсли; 
		
	КонецЦикла;
	
	Результат = Новый Структура;
	Если АтрибутыНесоответствия.Количество() Тогда
		ОписаниеОшибки = "Атрибуты не соответствуют карточке Local ";
		Для каждого Атрибут Из АтрибутыНесоответствия Цикл
			ОписаниеОшибки = ОписаниеОшибки + Атрибут+"; ";
		КонецЦикла; 
		Результат.Вставить("error", ОписаниеОшибки);
	Иначе
		Результат.Вставить("result", Истина);
	КонецЕсли; 
	
	Возврат Результат;
	
КонецФункции // ПроверитьСоответствиеНайденныхАтрибутовGlobalLocal()

Функция НайтиАтрибутыGlobal(ОтветСтрока, Атрибуты, ПоляКодовОтветаGlobal)

	АтрибутыРезультат = Новый Структура;
	
	Для каждого Атрибут Из Атрибуты Цикл
		//Атрибут.Ключ - Имя атрибутного реквизита
		//Атрибут.Значение - Имя атрибутного справочника
		АтрибутыРезультат.Вставить(Атрибут.Ключ, Справочники[Атрибут.Значение.Catalog].НайтиПоКоду(ОтветСтрока[ПоляКодовОтветаGlobal[Атрибут.Ключ]]));
	КонецЦикла;
	
	Возврат АтрибутыРезультат;

КонецФункции // НайтиАтрибутыGlobal()
 
Функция СоздатьАтрибутыGlobal(ОтветСтрока, НайденныеАтрибуты, АтрибутыGlobal, InteractiveMode)
	
	Ответ = Новый Структура;
	
	Для каждого Атрибут Из НайденныеАтрибуты Цикл
		//Атрибут.Ключ - Имя атрибутного реквизита
		//Атрибут.Значение - Значение атрибутного реквизита
		Если НЕ ЗначениеЗаполнено(Атрибут.Значение) Тогда
			
			Если АтрибутыGlobal[Атрибут.Ключ].IsGroup Тогда
				Результат = MDMСервер.interface(Атрибут.Значение).NewGroupAttribute(ОтветСтрока);
			Иначе
				Результат = MDMСервер.interface(Атрибут.Значение).NewAttribute(ОтветСтрока);
			КонецЕсли; 
			
			result = Неопределено;
			error = Неопределено;
			Если Результат.Свойство("result", result) Тогда
				НайденныеАтрибуты[Атрибут.Ключ] = result;
			ИначеЕсли Результат.Свойство("error", error) Тогда
				Ответ.Вставить("error", НСтр(error, "ru"));
				Возврат Ответ;
			КонецЕсли; 
		КонецЕсли; 
	КонецЦикла;
	
	Ответ.Вставить("result", Истина);
	
	Возврат Ответ;

КонецФункции // СоздатьАтрибуты(СсылкаGlobal, ОтсутствующиеАтрибуты, ОтветСтрока)()

Функция УстановитьСоответствиеАтрибутовGlobalLocal(АтрибутыGlobal, СсылкаLocal, СоответствияGlobalLocal, InteractiveMode)
	
	Ответ = Новый Структура;
	
	Для каждого Атрибут Из АтрибутыGlobal Цикл
		СоответствиеGlobalLocal = СоответствияGlobalLocal[Атрибут.Ключ];
		ИзмерениеGlobal = СоответствиеGlobalLocal.ИзмерениеGlobal;
		НаборЗаписей = РегистрыСведений[СоответствиеGlobalLocal.MappingTable].СоздатьНаборЗаписей();
		НаборЗаписей.Отбор[ИзмерениеGlobal].Установить(Атрибут.Значение);
		НаборЗаписей.Прочитать();
		Если НЕ НаборЗаписей.Количество() Тогда
			НоваяЗапись = НаборЗаписей.Добавить();
			НоваяЗапись[ИзмерениеGlobal] = Атрибут.Значение;
			ЗаполнитьЗначенияСвойств(НоваяЗапись, СсылкаLocal, СоответствиеGlobalLocal.ИзмеренияLocal);
			Попытка
				НаборЗаписей.Записать();
			Исключение
				ОтправитьУведомление(ОписаниеОшибки(), УровеньЖурналаРегистрации.Ошибка, InteractiveMode);
				Ответ.Вставить("error", ОписаниеОшибки());
				Возврат Ответ;
			КонецПопытки;
		КонецЕсли; 
	КонецЦикла;
	
	Ответ.Вставить("result", Истина);
	
	Возврат Ответ;
	
КонецФункции // УстановитьСоответствиеАтрибутовGlobalLocal()

//Интерфейс Global
Функция GlobalEntities(DataKey = Неопределено) Экспорт 
	
	entities = Новый Структура;
	
	DataKeys = Новый Структура;
	DataKeys.Вставить("GlobalSKU", "SKUMDM");
	DataKeys.Вставить("GlobalPartners", "PRTMDM");
	
	Если DataKey = Неопределено Тогда
		Для каждого DataKey Из DataKeys Цикл
			entities.Вставить(DataKey.Ключ, Справочники.Обмены.ПолучитьНастройку(DataKey.Значение));
		КонецЦикла; 
	Иначе
		ExchangeID = "";
		Если DataKeys.Свойство(DataKey, ExchangeID) Тогда
			entities.Вставить(DataKey, Справочники.Обмены.ПолучитьНастройку(ExchangeID));
		Иначе
			entities.Вставить("error", "Неизвестный ключ данных "+DataKey);
		КонецЕсли; 
	КонецЕсли;
	
	Возврат entities;

КонецФункции // Entities()

Функция NewAttribute(ИмяАтрибутногоСправочника, Реквизиты) Экспорт 

	Ответ = Новый Структура;
	
	Объект = Справочники[ИмяАтрибутногоСправочника].СоздатьЭлемент();
	ЗаполнитьЗначенияСвойств(Объект, Реквизиты);
	Попытка
		Объект.Записать();
		Ответ.Вставить("result", Объект.Ссылка);
	Исключение
		СтрокаРеквизитов = "";
		Для каждого Реквизит Из Реквизиты Цикл
			СтрокаРеквизитов = СтрокаРеквизитов+Реквизит.Ключ+": "+Реквизит.Значение+". ";
		КонецЦикла; 
		Ответ.Вставить("error", "Не удалось записать "+Объект.Метаданные().Синоним+". " + СтрокаРеквизитов + " Описание ошибки (" + ОписаниеОшибки()+")");
	КонецПопытки;
	
	Возврат Ответ;

КонецФункции

// Операции с БД

// Выполняет выборку из базы данных SQL
//
// Параметры:
//  arguments  - Структура - структура содержащая аргументы функции
//				 dbTableName - 
//				 ArrayGUID - 
//               dbConnectionSet -
//
// Возвращаемое значение:
//   Структура   - структура содержащая в случае успешного выполнения элемент
//					result - таблица значений полученная из базы данных, в случае ошибки элемент 
//                  error - текстовое описание ошибки выполнения функции
Функция dbRead(dbConnection, interactiveMode, dbTableName, ArrayGUID) Экспорт
	
	connectionADODB = Неопределено;
	Если dbConnection.Свойство("result", connectionADODB) Тогда
		
		Результат = Новый Структура;
		
		ТекстИнструкции =
		"SELECT
		|   *
		|FROM "+dbTableName;
		
		Если ArrayGUID.Количество() Тогда
			ТекстИнструкции = ТекстИнструкции +"
			|WHERE [GUID]=N'"+ArrayGUID[0]+"'";
		КонецЕсли; 
		
		Попытка
			dbCommand = connectionADODB.dbCommand;
			dbCommand.CommandText = ТекстИнструкции;
			
			Результат.Вставить("result", ПолучитьТаблицуИзВыборки(dbCommand.Execute()));
		Исключение
			Результат.Вставить("error", ОписаниеОшибки());
		КонецПопытки;	
		
		closeConnectionError = Неопределено;
		Если CloseConnectionADODB(connectionADODB).Свойство("error", closeConnectionError) Тогда
			ОтправитьУведомление(closeConnectionError, УровеньЖурналаРегистрации.Ошибка, interactiveMode);
		КонецЕсли;
		
	Иначе
		Результат = dbConnection;
	КонецЕсли; 
	
	Возврат Результат;
	
КонецФункции // dbRead()

// Выполняет добавление новой строки в базу данных SQL
//
// Параметры:
//  arguments  - Структура - структура содержащая аргументы функции
//               dbTableName -
//               DataSet - 
//               dbConnectionSet -
//
// Возвращаемое значение:
//   Структура   - структура содержащая в случае успешного выполнения элемент
//					result - Истина, в случае ошибки элемент 
//                  error - текстовое описание ошибки выполнения функции
Функция dbCreate(dbConnection, interactiveMode, dbTableName, DataSet) Экспорт
	
	connectionADODB = Неопределено;
	Если dbConnection.Свойство("result", connectionADODB) Тогда
		
		Результат = Новый Структура;
		
		dbFields = "";
		dbValues = "";
		Для каждого DataSetItem Из DataSet Цикл
			dbFields = dbFields+СтрЗаменить("[fieldName],","fieldName",DataSetItem.Ключ);
			dbValues = dbValues+СтрЗаменить("'value',","value",Строка(DataSetItem.Значение));
		КонецЦикла;
		
		СтроковыеФункцииКлиентСервер.УдалитьПоследнийСимволВСтроке(dbFields, 1);
		СтроковыеФункцииКлиентСервер.УдалитьПоследнийСимволВСтроке(dbValues, 1);
		
		ТекстТекущейИнструкции =                                                                                               
		"INSERT INTO "+dbTableName+"                                                                                                                           
		|(dbFields)
		|VALUES (dbValues)";
		
		ТекстТекущейИнструкции = СтрЗаменить(ТекстТекущейИнструкции,"dbFields",dbFields);
		ТекстТекущейИнструкции = СтрЗаменить(ТекстТекущейИнструкции,"dbValues",dbValues);
		
		Попытка
			connectionADODB.dbConnection.Execute(ТекстТекущейИнструкции,,128);
			Результат.Вставить("result", Истина);
		Исключение
			Результат.Вставить("error", ОписаниеОшибки());
		КонецПопытки;
		
		closeConnectionError = Неопределено;
		Если CloseConnectionADODB(connectionADODB).Свойство("error", closeConnectionError) Тогда
			ОтправитьУведомление(closeConnectionError, УровеньЖурналаРегистрации.Ошибка, interactiveMode);
		КонецЕсли;
		
	Иначе
		Результат = dbConnection;
	КонецЕсли; 
	
	Возврат Результат;
	
КонецФункции // dbCreate()

// Выполняет обновление записи в базе данных SQL
//
// Параметры:
//  arguments  - Структура - структура содержащая аргументы функции
//               dbTableName -
//               ArrayGUID - 
//               DataSet - 
//               dbConnectionSet -
//
// Возвращаемое значение:
//   Структура   - структура содержащая в случае успешного выполнения элемент
//					result - Истина, в случае ошибки элемент 
//                  error - текстовое описание ошибки выполнения функции
Функция dbUpdate(dbConnection, interactiveMode, dbTableName, ArrayGUID, DataSet) Экспорт
	
	connectionADODB = Неопределено;
	Если dbConnection.Свойство("result", connectionADODB) Тогда
		
		Результат = Новый Структура;
		
		ТекстТекущейИнструкции =
		"UPDATE "+dbTableName+"
		|SET";
		
		Для каждого DataSetItem Из DataSet Цикл
			ТекстТекущейИнструкции = ТекстТекущейИнструкции+"
			|   ["+DataSetItem.Ключ+"] = '"+DataSetItem.Значение+"',";
		КонецЦикла;
		
		ТекстТекущейИнструкции = Лев(ТекстТекущейИнструкции, СтрДлина(ТекстТекущейИнструкции)-1);
		ТекстТекущейИнструкции = ТекстТекущейИнструкции+"
		|WHERE [GUID]=N'"+ArrayGUID[0]+"'";
		
		Попытка
			connectionADODB.dbConnection.Execute(ТекстТекущейИнструкции,,128);
			Результат.Вставить("result", Истина);
		Исключение
			Результат.Вставить("error", ОписаниеОшибки());
		КонецПопытки;
		
		closeConnectionError = Неопределено;
		Если CloseConnectionADODB(connectionADODB).Свойство("error", closeConnectionError) Тогда
			ОтправитьУведомление(closeConnectionError, УровеньЖурналаРегистрации.Ошибка, interactiveMode);
		КонецЕсли;
		
	Иначе
		Результат = dbConnection;
	КонецЕсли; 
	
	Возврат Результат;
	
КонецФункции // dbUpdate()

// Выполняет удаление записи из базы данных SQL
//
// Параметры:
//  arguments  - Структура - структура содержащая аргументы функции
//				 dbTableName - 
//				 ArrayGUID - 
//               dbConnectionSet -
//
// Возвращаемое значение:
//   Структура   - структура содержащая в случае успешного выполнения элемент
//					result - Истина, в случае ошибки элемент 
//                  error - текстовое описание ошибки выполнения функции
Функция dbDelete(dbConnection, interactiveMode, dbTableName, ArrayGUID) Экспорт
	
	connectionADODB = Неопределено;
	Если dbConnection.Свойство("result", connectionADODB) Тогда
		
		Результат = Новый Структура;
		
		ТекстТекущейИнструкции =
		"DELETE FROM "+dbTableName+"
		|WHERE [GUID]=N'"+ArrayGUID[0]+"'";
		
		Попытка
			connectionADODB.dbConnection.Execute(ТекстТекущейИнструкции,,128);
			Результат.Вставить("result", Истина);
		Исключение
			Результат.Вставить("error", ОписаниеОшибки());
		КонецПопытки;
		
		closeConnectionError = Неопределено;
		Если CloseConnectionADODB(connectionADODB).Свойство("error", closeConnectionError) Тогда
			ОтправитьУведомление(closeConnectionError, УровеньЖурналаРегистрации.Ошибка, interactiveMode);
		КонецЕсли;
		
	Иначе
		Результат = dbConnection;
	КонецЕсли; 
	
	Возврат Результат;
	
КонецФункции // dbDelete()

Функция ConnectionParameters() Экспорт 
	
	Возврат Справочники.Обмены.ПолучитьНастройку("GMDM");
	
КонецФункции // ConnectionParameters()

Функция OpenConnectionADODB(ConnectionParameters) Экспорт 
	
	Результат = Новый Структура;
	
	Попытка
		
		dbConnection  = Новый COMОбъект("ADODB.Connection");
		dbCommand     = Новый COMОбъект("ADODB.Command");
		dbRecordSet   = Новый COMОбъект("ADODB.RecordSet");
		
		dbConnection.ConnectionString =
		"driver={SQL Server};" +
		"server="+ConnectionParameters.ServerName+";"+
		"uid="+ConnectionParameters.User+";"+
		"pwd="+ConnectionParameters.Password+";"+
		"database="+ConnectionParameters.DataBaseName+";";
		
		dbConnection.ConnectionTimeout = 30;
		dbConnection.CommandTimeout = 600;
		dbConnection.Open();
		dbCommand.ActiveConnection   = dbConnection;
		
		dbConnectionSet = Новый Структура;
		dbConnectionSet.Вставить("dbConnection",dbConnection);
		dbConnectionSet.Вставить("dbCommand",dbCommand);
		dbConnectionSet.Вставить("dbRecordSet",dbRecordSet);
		
		Результат.Вставить("result", dbConnectionSet);
		
	Исключение
		
		Результат.Вставить("error", ОписаниеОшибки());
		
	КонецПопытки;
	
	Возврат Результат;
	
КонецФункции

Функция CloseConnectionADODB(dbConnectionSet)

	Результат = Новый Структура;
	
	Попытка
		dbConnectionSet.dbConnection.Close();
		Результат.Вставить("result", Истина);
	Исключение
		Результат.Вставить("error", ОписаниеОшибки());
	КонецПопытки;
	
	Возврат Результат;
	
КонецФункции // ()

Функция ПолучитьТаблицуИзВыборки(dbSelection)

	ТЗ = Новый ТаблицаЗначений;
	
	Если НЕ dbSelection = Неопределено
		И dbSelection.BOF = Ложь Тогда
		
		dbSelection.MoveFirst();
		
		Пока dbSelection.EOF = Ложь Цикл
			НоваяСтрока = ТЗ.Добавить();
			Для каждого Field Из dbSelection.Fields Цикл
				Если ТЗ.Колонки.Найти(Field.Name) = Неопределено Тогда
					ТЗ.Колонки.Добавить(Field.Name);
				КонецЕсли;
				НоваяСтрока[Field.Name] = Field.Value;
			КонецЦикла; 
			
			dbSelection.MoveNext();
		КонецЦикла;
		
	КонецЕсли;
	
	Возврат ТЗ;

КонецФункции // ConvertDataFromSQLtoXML()

//SYNC Global SQL

Функция ОтправитьНаСогласование(Объект, InteractiveMode) Экспорт 

	Результат = ВыгрузитьОбъектВБазуОбмена(Объект.Ссылка, InteractiveMode);
	
	error = Неопределено;
	Если Результат.Свойство("result") Тогда
		Объект.State = Перечисления.States.InProgress;
		Объект.TimeStamp = ТекущаяДата();
		Если ПустаяСтрока(Объект.GlobalID) Тогда
			Объект.GlobalID = Объект.Ссылка.УникальныйИдентификатор();
		КонецЕсли; 
	ИначеЕсли Результат.Свойтство("error", error) Тогда
		ОтправитьУведомление(error, УровеньЖурналаРегистрации.Ошибка, InteractiveMode);
	КонецЕсли; 

	Возврат Объект;
	
КонецФункции // ОтправитьНаСогласование()
 
Функция ВыгрузитьОбъектВБазуОбмена(ОбъектСсылка, interactiveMode) Экспорт 
	
	entityName = ОбъектСсылка.Метаданные().Имя;
	Interface = Справочники[entityName];

	Entity = GlobalEntities(entityName)[entityName];
	
	сonnectionParameters = ConnectionParameters();
	
	ArrayGUID = Новый Массив();
	ArrayGUID.Добавить(Строка(ОбъектСсылка.УникальныйИдентификатор()));
	
	//Проверяем наличие записи в основной таблице по GUID
	Ответ = dbRead(OpenConnectionADODB(сonnectionParameters), interactiveMode, Entity.MainTableName, ArrayGUID); //чтение
	
	ВыборкаТаблица = Неопределено;
	Если Ответ.Свойство("result", ВыборкаТаблица) Тогда
		
		DataSet = Interface.GetDataSet(ОбъектСсылка);
		DataSet.Вставить("Status", Строка(ОбъектСсылка.Status));
		DataSet.Вставить("IsNew", 1);
		
		//Обновляем или создаем новую запись в основной таблице
		Если ВыборкаТаблица.Количество() Тогда
			Ответ = dbUpdate(OpenConnectionADODB(сonnectionParameters), interactiveMode, Entity.MainTableName, ArrayGUID, DataSet); //обновление
		Иначе
			Ответ = dbCreate(OpenConnectionADODB(сonnectionParameters), interactiveMode, Entity.MainTableName, DataSet); //добавление
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат Ответ;

КонецФункции // ВыгрузитьОбъектВБазуОбмена()

Функция ИзменитьСтатусGlobal_SQL(globalСсылка, НовыйСтатус) Экспорт

	DataKey = globalСсылка.Метаданные().Имя;
	entity = GlobalEntities(DataKey)[DataKey];
	
	СтатусИзменен = Ложь;
	GlobalОбъект = globalСсылка.ПолучитьОбъект();
	GlobalОбъект.Status = НовыйСтатус;
	Попытка
		GlobalОбъект.Записать();
		СтатусИзменен = Истина;
		
		ArrayGUID = Новый Массив;
		ArrayGUID.Добавить(globalСсылка.УникальныйИдентификатор());
		
		DataSet = Новый Структура;
		DataSet.Вставить("IsNew", "2");
		DataSet.Вставить("Status", Строка(НовыйСтатус));
		Результат = dbUpdate(OpenConnectionADODB(ConnectionParameters()), Истина, entity.MainTableName, ArrayGUID, DataSet);
	Исключение
		Сообщить("Не удалось изменить статус.");
		Сообщить(ОписаниеОшибки());
	КонецПопытки;
	
	Возврат СтатусИзменен;
	
КонецФункции // ИзменитьСтатусGlobalНаСервере()

Функция ОтозватьЗапросGlobalID_SQL(globalСсылка) Экспорт 

	DataKey = globalСсылка.Метаданные().Имя;
	entity = GlobalEntities(DataKey)[DataKey];
	
	сonnectionParameters = ConnectionParameters();
	
	ArrayGUID = Новый Массив();
	ArrayGUID.Добавить(Строка(globalСсылка.УникальныйИдентификатор()));
	
	Ответ = GlobEx.dbRead(OpenConnectionADODB(сonnectionParameters), Истина, Entity.MainTableName, ArrayGUID); //чтение
	
	ЗапросОтозван = Ложь;
	ВыборкаТаблица = Неопределено;
	Если Ответ.Свойство("result", ВыборкаТаблица) Тогда
		
		Если ВыборкаТаблица.Количество() Тогда
			Если ВыборкаТаблица[0].IsNew = "1" Тогда
				
				DataSet = Новый Структура;
				DataSet.Вставить("IsNew", "0");
				
				error = "";
				Результат = dbUpdate(OpenConnectionADODB(ConnectionParameters()), Истина, entity.MainTableName, ArrayGUID, DataSet);
				Если Результат.Свойство("result", ЗапросОтозван) Тогда
					GlobalОбъект = globalСсылка.ПолучитьОбъект();
					GlobalОбъект.State = Перечисления.States.ПустаяСсылка();
					Попытка
						GlobalОбъект.Записать();
					Исключение
						Сообщить("Запрос отозван. Ошибка на стороне 1C: MDM. Не удалось записать состояние обмена для объекта.");
						Сообщить(ОписаниеОшибки());
					КонецПопытки;
				ИначеЕсли Результат.Свойство("error", error) Тогда
					Сообщить("Не удалось отозвать запрос. Ошибка СУБД: "+error);
				КонецЕсли; 
			ИначеЕсли ВыборкаТаблица[0].IsNew = "0" Тогда
				Сообщить("Не удалось отозвать запрос. Запрос находится в обработке.");
			Иначе
				Сообщить("Не удалось отозвать запрос. Неожиданное значение свойства IsNew "+ВыборкаТаблица[0].IsNew);
			КонецЕсли;
		Иначе
			Сообщить("Не удалось отозвать запрос. Не найден искомый элемент в базе обмена "+globalСсылка.LocalEntity.Код);
		КонецЕсли;
	КонецЕсли;
	
	Возврат ЗапросОтозван;

КонецФункции // ОтозватьЗапросGlobalID(GlobalSKU)()

Функция ДеактивацияGlobal_SQL(globalСсылка, DeactivationStatus, УдалитьЗапись) 

	DataKey = globalСсылка.Метаданные().Имя;
	entity = GlobalEntities(DataKey)[DataKey];
	
	ЗаписьДеактивирована = Ложь;
	GlobalОбъект = globalСсылка.ПолучитьОбъект();
	GlobalОбъект.Status = DeactivationStatus;
	Попытка
		GlobalОбъект.Записать();
		
		ArrayGUID = Новый Массив;
		ArrayGUID.Добавить(globalСсылка.УникальныйИдентификатор());
		
		Если УдалитьЗапись Тогда
			Результат = dbDelete(OpenConnectionADODB(ConnectionParameters()), Истина, entity.MainTableName, ArrayGUID);
		Иначе
			DataSet = Новый Структура;
			DataSet.Вставить("IsNew", "2");
			DataSet.Вставить("Status", Строка(DeactivationStatus));
			Результат = dbUpdate(OpenConnectionADODB(ConnectionParameters()), Истина, entity.MainTableName, ArrayGUID, DataSet);
		КонецЕсли;
		
		ЗаписьДеактивирована = Результат.Свойство("result");
	Исключение
		Сообщить("Не удалось деактивировать запись.");
		Сообщить(ОписаниеОшибки());
	КонецПопытки;
	
	Возврат ЗаписьДеактивирована;

КонецФункции // ДеактивацияGlobal()

Функция ДеактивацияGlobal(СсылкаGlobal, DeactivationStatus) Экспорт 
	
	DataKey = СсылкаGlobal.Метаданные().Имя;
	
	СсылкаLocal = СсылкаGlobal.LocalEntity;
	ОбъектLocal = СсылкаLocal.ПолучитьОбъект();
	
	СтрокаGlobalID = ОбъектLocal.GlobalID.Найти(СсылкаGlobal, DataKey);
	Если СтрокаGlobalID = Неопределено Тогда
		Сообщить("Непредвиденная ошибка. Не удалось найти строку Global ID " + СсылкаGlobal);
		Возврат Ложь;
	Иначе
		СтрокаGlobalID_Deact = ОбъектLocal.GlobalID_Deactivated.Добавить();
		ЗаполнитьЗначенияСвойств(СтрокаGlobalID_Deact, СтрокаGlobalID);
		ОбъектLocal.GlobalID.Удалить(СтрокаGlobalID);
		
		GlobalID = СсылкаGlobal.GlobalID;
		GlobalIDsLoc = ОбъектLocal.GlobalIDs;
		Если НЕ ПустаяСтрока(GlobalID) 
			И СтрНайти(GlobalIDsLoc, GlobalID)>0 Тогда
			Если СтрНайти(GlobalIDsLoc, GlobalID+"; ")>0 Тогда
				ОбъектLocal.GlobalIDs = СтрЗаменить(GlobalIDsLoc,GlobalID+"; ","");
			ИначеЕсли СтрНайти(GlobalIDsLoc, GlobalID)>0 Тогда
				ОбъектLocal.GlobalIDs = СтрЗаменить(GlobalIDsLoc,GlobalID,"");
			КонецЕсли; 
		КонецЕсли; 
		
		Попытка
			ОбъектLocal.Записать();
			ПланыОбмена.Обмен_МДМ_УПП.ВыполнитьРегистрациюДляУПП(СсылкаLocal);
		Исключение
			Сообщить("Не удалось записать объект " + СсылкаLocal);
			Сообщить(ОписаниеОшибки());
			Возврат Ложь;
		КонецПопытки;
	КонецЕсли; 
	
	Approved = СсылкаGlobal.State = ПредопределенноеЗначение("Перечисление.States.Approved");
	
	Возврат ДеактивацияGlobal_SQL(СсылкаGlobal, DeactivationStatus, НЕ Approved);

КонецФункции

//служебные
Функция ФорматироватьЧисло(Знач Параметр) Экспорт  
	Параметр = СтрЗаменить(Параметр,",",".");
	Параметр = СтрЗаменить(Параметр,Символы.НПП,"");
	Возврат Параметр;
КонецФункции

Процедура ОтправитьУведомление(ТекстУведомления, УровеньЖР, interactiveMode) Экспорт  
	
	ТекстУведомления = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
	НСтр("ru = '""%1"".'"),
	ТекстУведомления);
	
	ЗаписьЖурналаРегистрации("EXCHANGE Global MDM (SQL)",УровеньЖР,,,ТекстУведомления);
	Если interactiveMode Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстУведомления);
	КонецЕсли; 
	
КонецПроцедуры // ОтправитьУведомление()

Функция ProtectedStates() Экспорт  

	StatesArray = Новый Массив;
	StatesArray.Добавить(Перечисления.States.InProgress);
	StatesArray.Добавить(Перечисления.States.Approved);
	StatesArray.Добавить(Перечисления.States.Rejected);
	
	Возврат StatesArray;

КонецФункции // ProtectedStates()

