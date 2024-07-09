CREATE TABLE IF NOT EXISTS libby_cards_cardBody (
    _id TEXT PRIMARY KEY NOT NULL,
    userEmail TEXT NOT NULL,
    deck TEXT NOT NULL,
    id TEXT NOT NULL,
    front TEXT,
    frontImage TEXT,
    frontFontSize INTEGER,
    frontHasImage BOOLEAN,
    frontWatermark INTEGER,
    back TEXT,
    backImage TEXT,
    backFontSize INTEGER,
    backHasImage BOOLEAN,
    backWatermark INTEGER,
    isNew BOOLEAN,
    deleted BOOLEAN
)