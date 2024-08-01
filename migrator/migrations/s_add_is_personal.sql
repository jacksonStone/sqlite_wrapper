-- DATABASE mo_links

ALTER TABLE mo_links_organizations ADD COLUMN is_personal BOOLEAN NOT NULL DEFAULT FALSE;
