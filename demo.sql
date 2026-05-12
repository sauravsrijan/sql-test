-- Demo SQL file showcasing 5 of the most impactful SQLFluff issues
-- Real-world e-commerce analytics scenario

-- Issue 1: AM05 - Ambiguous JOIN (cross join - missing join condition)
-- Also Issue 3: CV05 - Comparison with NULL (should use IS NULL)
SELECT
    u.user_id,
    u.user_name,
    o.order_total
FROM
    users u,
    orders o
WHERE
    u.deleted_at = NULL
GROUP BY
    u.user_id,
    order_total;

-- Issue 2: AM09 - LIMIT without ORDER BY (non-deterministic)
SELECT
    product_id,
    product_name,
    SUM(quantity) as total_qty
FROM
    order_items
GROUP BY
    product_id,
    product_name
LIMIT 10;

-- Issue 4: AL03 - Column expression without alias
SELECT
    customer_id,
    CONCAT(first_name, ' ', last_name) as full_name,
    CASE WHEN status = 'active' THEN 1 ELSE 0 END,
    DATE_PART('year', AGE(created_at)) as account_age_years
FROM
    customers
WHERE
    deleted_at IS NOT NULL;

-- Issue 5: AM06 - Inconsistent column references in GROUP BY
-- Using column position instead of name
SELECT
    orders.customer_id,
    orders.created_at,
    COUNT(*) as order_count,
    ROUND(AVG(orders.total), 2) as avg_order_value
FROM
    orders
    LEFT JOIN customers ON orders.customer_id = customers.id
WHERE
    orders.created_at >= DATE '2024-01-01'
    AND customers.status IS NULL
GROUP BY
    1,
    orders.created_at
ORDER BY
    order_count DESC;
