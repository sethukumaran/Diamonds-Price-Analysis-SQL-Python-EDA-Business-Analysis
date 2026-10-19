-- diamonds_analysis.sql
-- Dialect: SQLite-compatible SQL.
-- Load diamonds.csv into a table named diamonds before running.

-- 1. Data-quality / EDA checks
SELECT COUNT(*) AS rows FROM diamonds;

SELECT
  SUM(CASE WHEN carat IS NULL THEN 1 ELSE 0 END) AS null_carat,
  SUM(CASE WHEN cut IS NULL THEN 1 ELSE 0 END) AS null_cut,
  SUM(CASE WHEN color IS NULL THEN 1 ELSE 0 END) AS null_color,
  SUM(CASE WHEN clarity IS NULL THEN 1 ELSE 0 END) AS null_clarity,
  SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS null_price
FROM diamonds;

SELECT COUNT(*) AS duplicate_rows
FROM (
  SELECT carat, cut, color, clarity, depth, `table`, x, y, z, price
  FROM diamonds
  GROUP BY carat, cut, color, clarity, depth, `table`, x, y, z, price
  HAVING COUNT(*) > 1
);

-- 2. Create an analysis view:
-- Remove zero dimensions and exact duplicate records.
CREATE VIEW IF NOT EXISTS diamonds_clean AS
SELECT DISTINCT
  carat, cut, color, clarity, depth, `table`, x, y, z, price,
  x*y*z AS volume,
  price/carat AS price_per_carat
FROM diamonds
WHERE x > 0 AND y > 0 AND z > 0;

-- 3. Overall business KPIs
SELECT
  COUNT(*) AS diamond_count,
  SUM(price) AS total_value,
  AVG(price) AS avg_price,
  AVG(price/carat) AS avg_price_per_carat,
  MIN(price) AS min_price,
  MAX(price) AS max_price,
  AVG(carat) AS avg_carat
FROM diamonds_clean;

-- 4. Cut performance
SELECT
  cut,
  COUNT(*) AS units,
  SUM(price) AS total_value,
  AVG(price) AS avg_price,
  AVG(price/carat) AS avg_price_per_carat,
  AVG(carat) AS avg_carat
FROM diamonds_clean
GROUP BY cut
ORDER BY total_value DESC;

-- 5. Color performance
SELECT
  color,
  COUNT(*) AS units,
  SUM(price) AS total_value,
  AVG(price) AS avg_price,
  AVG(price/carat) AS avg_price_per_carat
FROM diamonds_clean
GROUP BY color
ORDER BY total_value DESC;

-- 6. Clarity performance
SELECT
  clarity,
  COUNT(*) AS units,
  SUM(price) AS total_value,
  AVG(price) AS avg_price,
  AVG(price/carat) AS avg_price_per_carat
FROM diamonds_clean
GROUP BY clarity
ORDER BY total_value DESC;

-- 7. Price bands for commercial segmentation
SELECT
  CASE
    WHEN price < 1000 THEN '< $1K'
    WHEN price < 2500 THEN '$1K-$2.5K'
    WHEN price < 5000 THEN '$2.5K-$5K'
    WHEN price < 10000 THEN '$5K-$10K'
    ELSE '$10K+'
  END AS price_band,
  COUNT(*) AS units,
  SUM(price) AS total_value,
  AVG(price) AS avg_price
FROM diamonds_clean
GROUP BY price_band
ORDER BY MIN(price);

-- 8. Carat bands
SELECT
  CASE
    WHEN carat < 0.5 THEN '<0.5 ct'
    WHEN carat < 1.0 THEN '0.5-<1.0 ct'
    WHEN carat < 1.5 THEN '1.0-<1.5 ct'
    WHEN carat < 2.0 THEN '1.5-<2.0 ct'
    ELSE '2.0+ ct'
  END AS carat_band,
  COUNT(*) AS units,
  SUM(price) AS total_value,
  AVG(price) AS avg_price
FROM diamonds_clean
GROUP BY carat_band
ORDER BY MIN(carat);

-- 9. Premium opportunities:
-- Highest revenue combinations of cut x color
SELECT
  cut, color,
  COUNT(*) AS units,
  SUM(price) AS total_value,
  AVG(price) AS avg_price,
  AVG(price/carat) AS avg_price_per_carat
FROM diamonds_clean
GROUP BY cut, color
ORDER BY total_value DESC
LIMIT 15;

-- 10. High-value inventory
SELECT *
FROM diamonds_clean
WHERE price >= 10000
ORDER BY price DESC
LIMIT 25;
