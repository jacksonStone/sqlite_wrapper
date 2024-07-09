CREATE TABLE tc_chatHistories (
    _id text PRIMARY KEY,
    theologianId text NOT NULL,
    userId text NOT NULL,
    messages text NOT NULL,
    FOREIGN KEY (theologianId) REFERENCES tc_theologians(_id),
    FOREIGN KEY (userId) REFERENCES tc_users(userId)

);