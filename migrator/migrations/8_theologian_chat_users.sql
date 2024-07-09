CREATE TABLE tc_users (
    userId TEXT PRIMARY KEY NOT NULL,
    userEmail TEXT NOT NULL,
    salt TEXT NOT NULL,
    password TEXT NOT NULL
);