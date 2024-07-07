CREATE TABLE IF NOT EXISTS libby_cards_user (
    _id TEXT PRIMARY KEY NOT NULL,
    userEmail TEXT NOT NULL,
    salt TEXT NOT NULL,
    password TEXT NOT NULL,
    displayName TEXT NOT NULL,
    validSession INTEGER NOT NULL,
    emailVerificationKey TEXT NOT NULL,
    verifiedEmail BOOLEAN NOT NULL,
    trialUser BOOLEAN NOT NULL,
    planExpiration INTEGER NOT NULL,
    stripCustomerId TEXT,
    stripLastProceedSessionId TEXT
)