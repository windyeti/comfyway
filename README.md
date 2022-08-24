# Важные моменты
* Maytoni, Mantra, Lightstar импорт по Названию
* Ledron - Остаток nil, во входящем файле нет Остатка. В магазине через доп поле "Поставщик"
* Ledron - товары с вариантами. Импорт по Артикулу товара -- Sku = sku + " " + (ID артикула), 
фид = ID артикула + ___ledron
* Swg - импорт по Артикулу
* Swg - Пустое поле Остаток или Цена -- товара не берем в приложение
* Elevel - импорт по Артикулу
* Isonex, Loft it, Favourite, Kinklight, Stluce - импорт по названию


Если клиент хочет вносить правки в магазине в товары ( и чтобы они не затирались при импорте ), но и получать новые товары поставщиков из приложения, то мы импортируем из приложения только новые товары каждого поставщика, то есть страые товары не трогаем, ибо он внес в них правки в магазине. это было по импорту новых товаров постащиков.

После импорта новых товаров поставщиков мы получаем из магазина в приложение все товары магазина (им присвоены магазином id варианта), синхронизируем их с товарами поставщиков -- остатки и цены поставщиков переносим в товары из магазина. дальше создаем csv для импорта цен и остатков, который импортируется в магазин по id варианта.

Services::CreateCsvUpdate -- апдейт остатков и цен в инсайлс.

Services::CreateXlsWithParams -- создание новых товаров поставщиков в инсайлс.

Порядок работы приложения по заданиям в Кроне.

# Тестирование
Оставляем активными пару товаров<br>
Проверяем что работает апдейт остатков и цен<br>
Проверяем удаление<br>
Проверяем создание новых товаров (удаление в приложении должно при апдейте товаров поставщика создать опять этот товар и импортировать его в магазин)

# Производитель-Поставщик-Параметр
* product.distributor # ==> сами заводим название поставщика
* product.vendor # ==> берется из данных от поставщика
* product.p1 параметры --- Поставщик: NAME --- # ==> сами заводим название поставщика, для фильтрации товаров в магазине


# Удаление товаров по Брендам
* Удаляем товары бренда **brand_name** из приложения и магазина.
```
r 'destroy_by_brand:start["brand_name"]'
```
* Параметры запятая (Опионально первый раз только)
(Одна и более цифра)(запятая)(одна ИЛИ ДВЕ цифры)<br>
999999<br>
Сделать пример преобразования: название параметра:было-стало<br>
* **Логика**
  * Обрабатываем только те параметры, в которых данные соответ. шаблону ```^\d+,\d{1,3}``` ==> (начало строки)(одна и более цифры)(запятая)(одна или две цифры)<br>
  *  Далее проверка: <br>
    * eсли после последних цифр есть что-то еще, то делаем ==> '999999';<br>
    * если (начало строки)(одна и более цифры)(запятая)(одна или две цифры)(конец строки), то заменяем запятую на точку.
``` value =~ /^\d+,\d{1,2}$/ ? value.gsub(/^\d+(,)\d{1,3}$/, '.') : "999999" ```
* 

# Апдейт существующих товаров в приложении и в магазине
* В приложении расставить новые правила для значений параметров<br>
* Запустить апдейт товаров от поставщиков<br>
* Создать по выбранному поставщику XLS (надо csv скачать из магазина и в приложение его закинуть)<br>
* Сделать апдейт товаров в магазине с изменением параметров

1 (пункт 4. из доработок) ODEON LIGHT, NOVOTECH, LUMION, СОНЕКС
