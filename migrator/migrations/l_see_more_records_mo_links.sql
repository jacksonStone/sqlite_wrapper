-- DATABASE mo_links
INSERT INTO mo_links_users (email, password_hash, verified_email) VALUES ('test@test.com2', 'fakehash', TRUE);
INSERT INTO mo_links_entries (name, url, created_by_user_id, organization_id) VALUES ('test2', 'https://bing.com', 2, 1);