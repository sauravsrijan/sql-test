select customer_id, order_amount
from orders
where order_date > '2024-01-01'
limit 10;

select customers.customer_id, order_id, amount
from customers
join orders on customers.id = orders.customer_id;

select p.product_id, p.name, c.category_name
from products p
join categories c;

select user_id, COUNT(*) as transaction_count
FROM user_transactions
where transaction_date >= '2024-01-01'
GROUP by user_id
ORDER BY transaction_count desc;

select u.user_id, u.email, u.created_at
from users u
join orders o on u.id = o.user_id
where u.status = 'active';
