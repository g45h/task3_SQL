-- Вывести количество фильмов в каждой категории, отсортировать по убыванию.

SELECT c.name, COUNT(f.film_id) AS film_count
FROM category AS c
JOIN film_category AS fc ON c.category_id = fc.category_id
JOIN film AS f ON fc.film_id = f.film_id
GROUP BY c.name
ORDER BY film_count DESC;


-- Вывести 10 актеров, чьи фильмы большего всего арендовали, отсортировать по убыванию.

SELECT a.first_name, a.last_name, (f.rental_duration * f.rental_rate) AS film_rate
FROM actor AS a
JOIN film_actor AS fa ON a.actor_id = fa.actor_id
JOIN film AS f ON fa.film_id = f.film_id
GROUP BY a.first_name, a.last_name, f.rental_duration, f.rental_rate
ORDER BY film_rate DESC
LIMIT 10;

-- Вывести категорию фильмов, на которую потратили больше всего денег.

SELECT c.name AS category_name, SUM(p.amount) AS total_amount
FROM category AS c
JOIN film_category AS fc ON c.category_id = fc.category_id
JOIN inventory AS i ON fc.film_id = i.film_id
JOIN rental AS r ON i.inventory_id = r.inventory_id
JOIN payment AS p ON r.rental_id = p.rental_id
GROUP BY category_name
ORDER BY total_amount DESC
LIMIT 1;

-- Вывести названия фильмов, которых нет в inventory. Написать запрос без использования оператора IN.

SELECT f.title
FROM film AS f
LEFT JOIN inventory AS i ON f.film_id = i.film_id
WHERE i.film_id IS NULL;

-- Вывести топ 3 актеров, которые больше всего появлялись в фильмах в категории “Children”. 
-- Если у нескольких актеров одинаковое кол-во фильмов, вывести всех.


SELECT first_name, last_name, entries_count
FROM (
	SELECT a.first_name, a.last_name, COUNT(a.actor_id) AS entries_count,
	RANK() OVER (ORDER BY COUNT(*) DESC) AS film_rank
	FROM actor AS a
	JOIN film_actor AS fa ON a.actor_id = fa.actor_id
	JOIN film AS f ON fa.film_id = f.film_id
	JOIN film_category AS fc ON fc.film_id = f.film_id
	JOIN category AS c ON c.category_id = fc.category_id
	WHERE c.name = 'Children'
	GROUP BY a.first_name, a.last_name, a.actor_id
	ORDER BY entries_count DESC
) AS subquery
WHERE film_rank <= 3;

-- Вывести города с количеством активных и неактивных клиентов (активный — customer.active = 1). 
-- Отсортировать по количеству неактивных клиентов по убыванию.

SELECT city.city, COUNT(CASE WHEN c.active = 1 THEN 1 ELSE NULL END) AS active, 
COUNT(CASE WHEN c.active = 0 THEN 1 ELSE NULL END) AS inactive
FROM customer AS c
JOIN address AS a ON c.address_id = a.address_id
JOIN city ON a.city_id = city.city_id
GROUP BY city.city, c.active
ORDER BY inactive DESC;

-- Вывести категорию фильмов, у которой самое большое кол-во часов суммарной аренды в городах 
-- (customer.address_id в этом city), и которые начинаются на букву “a”. 
-- То же самое сделать для городов в которых есть символ “-”. Написать все в одном запросе.

SELECT *
FROM (
    SELECT city.city, c.name AS category_name, SUM(f.rental_duration) AS total_hours
    FROM category AS c
    JOIN film_category AS fc ON c.category_id = fc.category_id
    JOIN film AS f ON fc.film_id = f.film_id
    JOIN inventory AS i ON f.film_id = i.film_id
    JOIN rental AS r ON i.inventory_id = r.inventory_id
    JOIN customer AS cs ON r.customer_id = cs.customer_id
    JOIN address AS a ON cs.address_id = a.address_id
    JOIN city ON a.city_id = city.city_id
    WHERE city.city LIKE 'A%'
    GROUP BY city.city, category_name
) AS query1
UNION
SELECT *
FROM (
    SELECT city.city, c.name AS category_name, SUM(f.rental_duration) AS total_hours
    FROM category AS c
    JOIN film_category AS fc ON c.category_id = fc.category_id
    JOIN film AS f ON fc.film_id = f.film_id
    JOIN inventory AS i ON f.film_id = i.film_id
    JOIN rental AS r ON i.inventory_id = r.inventory_id
    JOIN customer AS cs ON r.customer_id = cs.customer_id
    JOIN address AS a ON cs.address_id = a.address_id
    JOIN city ON a.city_id = city.city_id
    WHERE city.city LIKE '%-%'
    GROUP BY city.city, category_name
) AS query2
ORDER BY total_hours DESC;
