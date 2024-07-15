ALTER TABLE reverse_proxy_visits ADD COLUMN duration INTEGER;
ALTER TABLE reverse_proxy_visits DROP COLUMN fulfilled_time;
