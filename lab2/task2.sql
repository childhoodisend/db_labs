-- 1 Вывести количество продавцов
select count(*) from employees;


-- 2 Сколько продуктов стоят меньше 10$
select count(*) from products where price < 10.0;


-- 3 Найти цену самого дорогого продукта
select price from products order by price desc limit 1;


-- 4 Найти все самые дорогие продукты (с самой большой ценой)
select * from products where price in (select price from products order by price desc limit 1);


-- 5 Найти количество продуктов, название которых начинается на Metal Plate
select * from products where name like 'Metal Plate%';


-- 6 Найти среднюю цену продукта, в названии которых встречается слово Silver
select sum(price) / count(price) from products where name like '%Silver%';


-- 7 Сколько покупателей, которых зовут Alicia?
select count(*) from customers where firstname = 'Alicia';


-- 8 Сколько есть уникальных имен покупателей?
select count(*) from customers where firstname in (select distinct firstname from customers);


-- 9 У какого количества покупателей определена буква отчества?
select count(*) from customers where middleinitial is not null;


-- 10 Какая буква отчества самая популярная?

-- 11 У какого количества покупателей не определена буква отчества?

-- 12 У какого количества покупателей совпали имена? Вывести статистику для каждого имени.

-- 13 У какого количества покупателей совпали имена и отчества? Вывести статистику для каждого имени и отчества.

-- 14 Сколько однофамильцев среди продавцов

-- 15 Найти количество продаж продавца по имени Ann

-- 16 Вывести количество различных товаров, которые продает Ann

-- 17 Сколько продаж есть у каждого продавца?

-- 18 Сколько покупок у каждого покупателя?

-- 19 Скольким покупателям продавал товары каждый продавец?

-- 20 Какова средняя цена каждой продажи во всем продажам?

-- 21 Какова сумма продаж у каждого продавца?

-- 22 Для каждого товара найти мат.ожидание количества в каждой продаже и среднее квадратичное отклонение.

-- 23 Вывести информацию о продажах, в котором будут фамилии и имена продавцов, покупателей, название товаров, количество товаров,  цена за единицу и общая сумма продажи.

-- 24 Для всех продаж для каждого покупателя добавить  с помощью оконной функции общее количество купленных товаров за все время, и пронумеровать каждую покупку для каждого покупателя, начиная с 1.