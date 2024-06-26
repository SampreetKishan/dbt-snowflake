-- We are going to get customers.sql in the format of 
-- customer_id
-- customer_first_name
-- customer_last_name
-- customer_first_order_date
-- customer_most_recent_order_date
-- number of orders




with 
    customers as (
        select * from {{ ref('stg_customers')}}
    ),

    orders as (
        select  * from {{ ref('stg_orders') }}
    ),

    customer_orders as (
        select 
            customer_id,
            min(order_date) as first_order_date,
            max(order_date) as most_recent_order_date,
            count(order_id) as number_of_orders
        from orders 
        group by customer_id
    ),

    final_customer_orders as (
        select 
            customers.customer_id,
            customers.first_name,
            customers.last_name,
            customer_orders.first_order_date,
            customer_orders.most_recent_order_date,
            coalesce(customer_orders.number_of_orders,0) as number_of_orders

        FROM customers  
        LEFT JOIN customer_orders ON customers.customer_id = customer_orders.customer_id 
    )

    select * from final_customer_orders

