-- ecommerce_analytics.sql
-- Production demo showing 5 common SQLFluff issues
-- Real-world scenarios that can cause bugs in production

-- Issue 1: LIMIT without ORDER BY (AM09)
-- Non-deterministic results - gets different rows on each run
select customer_id, order_amount
from orders
where order_date > '2024-01-01'
limit 10;

-- Issue 2: Unqualified JOIN (AM05)
-- Ambiguous - unclear which table columns come from
select customers.customer_id, order_id, amount
from customers
join orders on customers.id = orders.customer_id;

-- Issue 3: Implicit cross join via missing condition (AM08)
-- Accidental Cartesian product - will multiply rows dramatically
select p.product_id, p.name, c.category_name
from products p
join categories c;

-- Issue 4: Inconsistent keyword capitalization (CP01)
-- Mixes LOWERCASE, UPPERCASE, MixedCase
select user_id, COUNT(*) as transaction_count
FROM user_transactions
where transaction_date >= '2024-01-01'
GROUP by user_id
ORDER BY transaction_count desc;

-- Issue 5: Unused/redundant alias (AL05)
-- Alias 'o' is defined but never used
select u.user_id, u.email, u.created_at
from users u
join orders o on u.id = o.user_id
where u.status = 'active';
