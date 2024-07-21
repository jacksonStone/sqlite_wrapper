-- DATABASE mo_links
INSERT INTO mo_links_users (email, password_hash, verified_email) VALUES ('test@test.com', 'fakehash', TRUE);
INSERT INTO mo_links_organizations (name, created_by_user_id) VALUES ('test organization', 1);
INSERT INTO mo_links_organization_memberships (organization_id, user_id, role) VALUES (1, 1, 'admin');
INSERT INTO mo_links_entries (name, url, created_by_user_id, organization_id) VALUES ('test', 'https://google.com', 1, 1);