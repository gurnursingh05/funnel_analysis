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