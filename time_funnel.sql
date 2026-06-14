WITH user_journey as(
	select 
		user_id,
		MIN(CASE WHEN event_type = 'page_view' THEN event_date end) as view_time,
		MIN(CASE WHEN event_type = 'add_to_cart' THEN event_date end) as cart_time,
		MIN(CASE WHEN event_type = 'checkout_start' THEN event_date end) as checkout_time,
		MIN(CASE WHEN event_type = 'payment_info' THEN event_date end) as payment_time,
		MIN(CASE WHEN event_type = 'purchase' THEN event_date end) as purchase_time
	from user_events
	where 
		event_date >= timestamp '2026-02-03' - interval '30 days'
	group by user_id
	having MIN(CASE WHEN event_type = 'purchase' THEN event_date end) is not NULL
)

SELECT 
	COUNT(*) AS converted_users,
	ROUND(AVG(EXTRACT(EPOCH FROM (cart_time - view_time)/60)),2) AS avg_view_to_cart_minutes,
	ROUND(AVG(EXTRACT(EPOCH FROM (checkout_time - cart_time)/60)),2) AS avg_cart_to_checkout_minutes,
	ROUND(AVG(EXTRACT(EPOCH FROM (payment_time - checkout_time)/60)),2) AS avg_checkout_to_payment_minutes,
	ROUND(AVG(EXTRACT(EPOCH FROM (purchase_time - payment_time)/60)),2) AS avg_payment_to_purchase_minutes,
	ROUND(AVG(EXTRACT(EPOCH FROM (purchase_time - view_time)/60)),2) AS avg_view_to_purchase_minutes
FROM 												
	user_journey