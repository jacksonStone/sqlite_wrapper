PRAGMA journal_mode = WAL;
PRAGMA synchronous = NORMAL;
PRAGMA temp_store = MEMORY;
CREATE TABLE mo_links_users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    email TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    verified_email BOOLEAN NOT NULL DEFAULT FALSE,
    verification_token TEXT,
    verification_token_expires_at DATETIME
);
CREATE TABLE mo_links_organizations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    FOREIGN KEY (created_by_user_id) REFERENCES mo_links_users (id)
);
CREATE TABLE mo_links_organization_memberships (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    organization_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    role TEXT NOT NULL DEFAULT 'member',
    FOREIGN KEY (organization_id) REFERENCES mo_links_organizations (id),
    FOREIGN KEY (user_id) REFERENCES mo_links_users (id)
);
CREATE TABLE mo_links_entries (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    name TEXT NOT NULL,
    url TEXT NOT NULL,
    views INTEGER NOT NULL DEFAULT 0,
    created_by_user_id INTEGER NOT NULL,
    organization_id INTEGER,
    FOREIGN KEY (created_by_user_id) REFERENCES mo_links_users (id),
    FOREIGN KEY (organization_id) REFERENCES mo_links_organizations (id)
);