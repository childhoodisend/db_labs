-- 1 Вывести всех продавцов
select * from employees;


-- 2 Вывести всех продавцов, отсортировав их по имени в лексикографическом порядке
select * from employees order by firstname;


-- 3 Найти всю информацию о продавце по имени Ann
select * from employees where firstname = 'Ann';


-- 4 Найти фамилию продавца по имени Ann
select lastname from employees where firstname = 'Ann';


-- 5 Определить самый большой номер [EmployeeID] продавца
select employeeid from employees order by employeeid desc limit 1;


-- 6 Найти продукты, которые стоят меньше 10$
select * from products where price < 10.0;


-- 7 Найти один самый дорогой продукт
select * from products order by price desc limit 1;


-- 8 Найти все самые дорогие продукты (с самой большой ценой)
select * from products where price = (select MAX(price) from products);


-- 9 Найти продукты, название которых начинается на Metal Plate
select * from products where name like 'Metal Plate%';


-- 10 Найти продукты, в названии которых встречается слово Silver
select * from products where name like '%Silver%';


-- 11 Найдите покупателей, которых зовут Alicia
select * from customers where firstname = 'Alicia';


-- 12 У кого их них определена буква отчества?
select * from customers where firstname = 'Alicia' and middleinitial is not null;


-- 13 А у кого не определена буква отчества?
select * from customers where firstname = 'Alicia' and middleinitial is null;


-- 14 Вывести все различные имена покупателей
select distinct firstname from customers;


-- 15 Найти однофамильцев среди продавцов
SELECT lastname, count(*) FROM employees group by lastname HAVING count(*) > 1;



-- 16 Найти продажи продавца по имени Ann
select * from sales join employees as empl on empl.firstname = 'Ann';


-- 17 Вывести названия товаров, которые продает Ann
select name from products where productid in (select productid from sales join employees as empl on empl.firstname = 'Ann');