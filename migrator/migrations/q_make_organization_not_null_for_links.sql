-- DATABASE mo_links

BEGIN TRANSACTION;

DROP TABLE mo_links_entries;

CREATE TABLE mo_links_entries (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    name TEXT NOT NULL,
    url TEXT NOT NULL,
    views INTEGER NOT NULL DEFAULT 0,
    created_by_user_id INTEGER NOT NULL,
    organization_id INTEGER NOT NULL,
    FOREIGN KEY (created_by_user_id) REFERENCES mo_links_users (id),
    FOREIGN KEY (organization_id) REFERENCES mo_links_organizations (id)
);

COMMIT;
