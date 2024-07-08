CREATE TABLE IF NOT EXISTS libby_cards_user (
    _id TEXT PRIMARY KEY NOT NULL,
    userEmail TEXT NOT NULL,
    salt TEXT NOT NULL,
    password TEXT NOT NULL,
    displayName TEXT,
    validSession INTEGER,
    emailVerificationKey TEXT,
    verifiedEmail BOOLEAN,
    trialUser BOOLEAN,
    planExpiration INTEGER,
    stripCustomerId TEXT,
    stripLastProceedSessionId TEXT,
    darkMode BOOLEAN,
    createdAt INTEGER,
    hideNavigation BOOLEAN,
    hideProgress BOOLEAN
)