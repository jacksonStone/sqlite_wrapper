CREATE TABLE IF NOT EXISTS libby_cards_deck (
    _id TEXT PRIMARY KEY NOT NULL,
    userEmail TEXT NOT NULL,
    displayName TEXT NOT NULL,
    name TEXT NOT NULL,
    id TEXT NOT NULL,
    date INTEGER NOT NULL,
    cards TEXT NOT NULL,
    lastModified INTEGER,
    "public" BOOLEAN
)