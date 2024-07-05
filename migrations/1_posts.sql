CREATE TABLE IF NOT EXISTS posts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    title TEXT NOT NULL,
    content TEXT,
    FOREIGN KEY(user_id) REFERENCES my_users(id)
);