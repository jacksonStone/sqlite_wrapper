CREATE TABLE IF NOT EXISTS libby_cards_studySession (
    _id TEXT PRIMARY KEY NOT NULL,
    userEmail TEXT NOT NULL,
    currentCard INTEGER,
    ordering TEXT NOT NULL,
    deck TEXT NOT NULL,
    id TEXT NOT NULL,
    date INTEGER NOT NULL,
    studyState TEXT NOT NULL
)