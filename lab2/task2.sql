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
select middleinitial from (select middleinitial, count(*) as cnt from Customers where customers.middleinitial is not null group by middleinitial) as countable order by cnt desc limit 1;


-- 11 У какого количества покупателей не определена буква отчества?
select count (*) from customers where customers.middleinitial is null;


-- 12 У какого количества покупателей совпали имена? Вывести статистику для каждого имени.
select firstname, count (*) as cnt from customers group by firstName;


-- 13 У какого количества покупателей совпали имена и отчества? Вывести статистику для каждого имени и отчества.
select firstname, middleinitial, count (*) as cnt from customers group by (firstName, middleinitial);


-- 14 Сколько однофамильцев среди продавцов
select lastname, count (*) as cnt from employees group by lastname;


-- 15 Найти количество продаж продавца по имени Ann
select count(*) from sales left join employees e on sales.salespersonid = e.employeeid and firstname = 'Ann';


-- 16 Вывести количество различных товаров, которые продает Ann
select count(distinct sales.ProductID) from sales join employees e on sales.salespersonid = e.employeeid and firstname = 'Ann';


-- 17 Сколько продаж есть у каждого продавца?
select (firstname, middleinitial, lastname), count(*) from sales join Employees on sales.SalesPersonID = Employees.EmployeeID group by (firstname, middleinitial, lastname);


-- 18 Сколько покупок у каждого покупателя?
select c.customerid, count(*) from sales join customers c on sales.customerid = c.customerid group by c.customerid order by c.customerid;


-- 19 Скольким покупателям продавал товары каждый продавец?
select employeeid, count(distinct s.customerid) from employees join sales s on employees.employeeid = s.salespersonid group by employeeid order by employeeid;


-- 20 Какова средняя цена каждой продажи во всем продажам?
select AVG(price) from sales join products p on sales.productid = p.productid;


-- 21 Какова сумма продаж у каждого продавца?
-- create idx's ?
select sales.salespersonid, SUM(price) from sales join products p on sales.productid = p.productid group by salespersonid;


-- 22 Для каждого товара найти мат.ожидание количества в каждой продаже и среднее квадратичное отклонение.
drop view if exists E cascade;
create view E as (select sales.productid, sum(sales.quantity)/count(sales.productid) as mean from sales join products as p on sales.productid = p.productid group by sales.productid);

select salesid, E.mean, sum((E.mean - sales.quantity)*(E.mean - sales.quantity))/count(sales.productid) as D from E join sales on E.productid = sales.salesid
group by salesid, E.mean;


-- 23 Вывести информацию о продажах, в котором будут фамилии и имена продавцов, покупателей, название товаров, количество товаров,  цена за единицу и общая сумма продажи.
select salesid, e.firstname , e.lastname, c.firstname, c.lastname, p.price, sum(quantity*price)
from sales as s
    join products  p on s.productid  = p.productid
    join customers c on s.customerid = c.customerid
    join employees e on s.salesid    = e.employeeid
group by salesid, e.firstname, salesid, e.lastname, c.firstname, c.lastname, p.price;


-- 24 Для всех продаж для каждого покупателя добавить  с помощью оконной функции общее количество купленных товаров за все время, и пронумеровать каждую покупку для каждого покупателя, начиная с 1.
select firstname, salesid, row_number() over () from sales join customers c on sales.customerid = c.customerid;
