-- DATABASE visits
CREATE TABLE reverse_proxy_website_visits (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    vistor_hash TEXT NOT NULL,
    url_without_params TEXT NOT NULL
);