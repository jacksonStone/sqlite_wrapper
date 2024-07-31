-- DATABASE mo_links

ALTER TABLE mo_links_users ADD COLUMN password_salt TEXT NOT NULL DEFAULT 'salt';
