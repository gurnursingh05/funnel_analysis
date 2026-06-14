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