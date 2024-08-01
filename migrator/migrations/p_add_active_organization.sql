-- DATABASE mo_links
PRAGMA foreign_keys = OFF;

-- Begin a transaction so I can add a new foreign key column
BEGIN TRANSACTION;
CREATE TABLE mo_links_users_new (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    email TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    password_salt TEXT NOT NULL,
    verified_email BOOLEAN NOT NULL DEFAULT FALSE,
    verification_token TEXT,
    verification_token_expires_at DATETIME,
    active_organization_id INTEGER,
    FOREIGN KEY (active_organization_id) REFERENCES mo_links_organizations(id)
);

-- Copy data from the old table to the new table
INSERT INTO mo_links_users_new (id, created_at, email, password_hash, password_salt, verified_email, verification_token, verification_token_expires_at)
SELECT id, created_at, email, password_hash, password_salt, verified_email, verification_token, verification_token_expires_at FROM mo_links_users;

DROP TABLE mo_links_users;

ALTER TABLE mo_links_users_new RENAME TO mo_links_users;
-- Commit the transaction
COMMIT;

-- Re-enable foreign key constraints
PRAGMA foreign_keys = ON;