# README

* Все товары поставщиков импорт в магазин через Название, кроме Swg - по Артикул
* Ledron - Остаток nil, во входящем файле нет Остатка. В магазине через доп поле "Поставщик"
* Ledron - товары с вариантами. Грузим по Артикулу варианта, и фид из него делаем + ___ledron
Sku = sku + " " + (ID артикула)
* Swg - Пустое поле Остаток или Цена -- товара не берем в приложение

если клиент хочет вносить правки в магазине в товары ( и чтобы они не затирались при импорте ), но и получать новые товары поставщиков из приложения, то мы импортируем из приложения только новые товары каждого поставщика, то есть страые товары не трогаем, ибо он внес в них правки в магазине. это было по импорту новых товаров постащиков.

после импорта новых товаров поставщиков мы получаем из магазина в приложение все товары магазина (им присвоены магазином id варианта), синхронизируем их с товарами поставщиков -- остатки и цены поставщиков переносим в товары из магазина. дальше создаем csv для импорта цен и остатков, который импортируется в магазин по id варианта.
