﻿
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
	Источник = ПараметрыВыполненияКоманды.Источник;
	ВыделенныеСтроки = Источник.Элементы[Источник.ТекущийЭлемент.Имя].ВыделенныеСтроки;
	Для каждого Значение Из ВыделенныеСтроки Цикл
		ВыполнитьРегистрациюНаСервере(Значение);
		ПоказатьОповещениеПользователя("Регистрация: "+Значение,,"Регистрация объектов",БиблиотекаКартинок.Успешно32,,);
	КонецЦикла;
	Оповестить("ОбновитьБуферОбмена");
	
КонецПроцедуры

// <Описание процедуры>
//
// Параметры:
//  <Параметр1>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>
//  <Параметр2>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>
//
&НаСервере
Процедура ВыполнитьРегистрациюНаСервере(Значение)

	ПланыОбмена.Обмен_МДМ_УПП.ВыполнитьРегистрациюДляУПП(Значение);
	
КонецПроцедуры // ВыполнитьРегистрациюНаСервере()
 