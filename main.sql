SELECT *
FROM user_events
order by event_date desc

SELECT 
	DISTINCT(traffic_source)
from user_events

--defining sales funnel	and stages of sales

WITH funnel_stages as(
	select 
		COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id end) as stage_1_view,
		COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id end) as stage_2_addtocart,
		COUNT(DISTINCT CASE WHEN event_type = 'checkout_start' THEN user_id end) as stage_3_checkout,
		COUNT(DISTINCT CASE WHEN event_type = 'payment_info' THEN user_id end) as stage_4_payment,
		COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id end) as stage_5_purchase
	from user_events
	where 
		event_date >= timestamp '2026-02-03' - interval '30 days'
)

select *
from funnel_stages


--conversion rates

WITH funnel_stages as(
	select 
		COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id end) as stage_1_view,
		COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id end) as stage_2_addtocart,
		COUNT(DISTINCT CASE WHEN event_type = 'checkout_start' THEN user_id end) as stage_3_checkout,
		COUNT(DISTINCT CASE WHEN event_type = 'payment_info' THEN user_id end) as stage_4_payment,
		COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id end) as stage_5_purchase
	from user_events
	where 
		event_date >= timestamp '2026-02-03' - interval '30 days'
)

SELECT
	stage_1_view,
	stage_2_addtocart,
	ROUND(stage_2_addtocart * 100 / stage_1_view) as view_to_cart_rate,
	stage_3_checkout,
	ROUND(stage_3_checkout * 100 / stage_2_addtocart) as addtocart_to_checkout_rate,
	stage_4_payment,
	ROUND(stage_4_payment * 100 / stage_3_checkout) as checkout_to_payment_rate,
	stage_5_purchase,
	ROUND(stage_5_purchase * 100 / stage_4_payment) as payment_to_purchase_rate,
	ROUND(stage_5_purchase * 100 / stage_1_view) as overall_conversion_rate
from funnel_stages


-- funneling by source

with funnel_source as (
	select 
		count(distinct case when traffic_source = 'social' THEN user_id end) as social_source,
		count(distinct case when traffic_source = 'email' THEN user_id end) as email_source,
		count(distinct case when traffic_source = 'organic' THEN user_id end) as organic_source,
		count(distinct case when traffic_source = 'paid_ads' THEN user_id end) as paid_ads_source
	from user_events
	where event_date >= date '2026-02-03' - interval '30 days'
)
select *
from funnel_source

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


-- time funnel
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

-- revenue funnel analysis

SELECT 
	user_id,
	amount,
	product_id
FROM
	user_events
WHERE
	amount IS NOT NULL
ORDER BY
	amount desc

WITH funnel_revenue AS (
	SELECT 
		COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id end) as total_visitors,
		COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id end) as total_buyers,
		SUM(CASE WHEN event_type = 'purchase' THEN amount END) as total_revenue
	FROM user_events
	WHERE
		event_date >= DATE '2026-02-03' - interval '30 days'
)

SELECT *,
	(total_buyers * 100  / total_visitors) AS net_purchase_rate,
	ROUND(total_revenue/total_buyers,2) AS net_purchase
FROM funnel_revenue