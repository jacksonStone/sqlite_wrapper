CREATE TABLE tc_chatRequests (
    _id text PRIMARY KEY,
    chatId text NOT NULL,
    userId text NOT NULL,
    sent text NOT NULL,
    timeSent integer NOT NULL,
    timeAnswered integer,
    FOREIGN KEY (chatId) REFERENCES tc_chatHistories(_id),
    FOREIGN KEY (userId) REFERENCES tc_users(userId)

);