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