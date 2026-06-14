WITH funnel_source as(
	select 
		traffic_source,
		COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id end) as views,
		COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id end) as cart,
		COUNT(DISTINCT CASE WHEN event_type = 'checkout_start' THEN user_id end) as checkout,
		COUNT(DISTINCT CASE WHEN event_type = 'payment_info' THEN user_id end) as payment,
		COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id end) as purchase
		
	from user_events
	where 
		event_date >= timestamp '2026-02-03' - interval '30 days'
	group by traffic_source
)

SELECT
	traffic_source,
	views,
	cart,
	checkout,
	payment,
	purchase,
	ROUND(cart * 100 / views) as view_to_cart_rate,
	ROUND(checkout * 100 / cart) as ocart_to_checkout_rate,
	ROUND(payment * 100 / checkout) as checkout_to_payment_rate,
	ROUND(purchase * 100 / payment) as payment_to_purchase_rate,
	ROUND(purchase * 100 / views) as overall_conversion_rate
FROM 
	funnel_source
ORDER BY 
	purchase desc