--MAIN PROJECT: Calculate churn rate for each segment

WITH months AS
  (SELECT
    '2017-01-01' as first_day,
    '2017-01-31' as last_day
  UNION
  SELECT
    '2017-02-01' as first_day,
    '2017-02-28' as last_day
  UNION
  SELECT
    '2017-03-01' as first_day,
    '2017-03-31' as last_day
  ),
cross_join AS (
  SELECT *
  FROM subscriptions
  CROSS JOIN months
),
status AS (
  SELECT 
    id, 
    first_day AS month, 
    CASE
      WHEN (segment = 87) AND (subscription_start < first_day) AND (subscription_end > first_day OR subscription_end IS NULL) THEN 1
      ELSE 0 
    END AS is_active_87,
    CASE
      WHEN (segment = 30) AND (subscription_start < first_day) AND (subscription_end > first_day OR subscription_end IS NULL) THEN 1
      ELSE 0 
    END AS is_active_30,
    CASE
     WHEN (segment = 87) AND (subscription_end BETWEEN first_day AND last_day) THEN 1
     ELSE 0
    END AS is_canceled_87,
    CASE
     WHEN (segment = 30) AND (subscription_end BETWEEN first_day AND last_day) THEN 1
     ELSE 0
    END AS is_canceled_30
  FROM cross_join
),
status_aggregate AS (
  SELECT 
    month, 
    SUM(is_active_87) AS sum_active_87, 
    SUM(is_active_30) AS sum_active_30, 
    SUM(is_canceled_87) AS sum_canceled_87, 
    SUM(is_canceled_30) AS sum_canceled_30
  FROM status
  GROUP BY month
)
SELECT 
  month, 
  1.0 * sum_canceled_87 / sum_active_87 AS churn_87, 
  1.0 * sum_canceled_30 / sum_active_30 AS churn_30
FROM status_aggregate;


--BONUS: How would you modify this code to support a large number of segments?

WITH months AS
  (SELECT
    '2017-01-01' as first_day,
    '2017-01-31' as last_day
  UNION
  SELECT
    '2017-02-01' as first_day,
    '2017-02-28' as last_day
  UNION
  SELECT
    '2017-03-01' as first_day,
    '2017-03-31' as last_day
  ),
cross_join AS (
  SELECT *
  FROM subscriptions
  CROSS JOIN months
),
status AS (
  SELECT 
    id, 
    first_day AS month, 
    segment,
    CASE
      WHEN (subscription_start < first_day) AND (subscription_end > first_day OR subscription_end IS NULL) THEN 1
      ELSE 0 
    END AS is_active,
    CASE
     WHEN (subscription_end BETWEEN first_day AND last_day) THEN 1
     ELSE 0
    END AS is_canceled
  FROM cross_join
),
status_aggregate AS (
  SELECT 
    month, 
    segment, 
    SUM(is_active) AS sum_active, 
    SUM(is_canceled) AS sum_canceled
  FROM status
  GROUP BY month, segment
)
SELECT 
  month, 
  segment, 
  1.0 * sum_canceled / sum_active AS churn_rate
FROM status_aggregate;