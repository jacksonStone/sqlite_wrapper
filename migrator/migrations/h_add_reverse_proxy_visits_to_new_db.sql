-- DATABASE visits
PRAGMA journal_mode = WAL;
PRAGMA synchronous = NORMAL;
PRAGMA temp_store = MEMORY;
CREATE TABLE reverse_proxy_visits (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    vistor_hash TEXT NOT NULL,
    url_without_params TEXT NOT NULL,
    duration INTEGER NOT NULL
);